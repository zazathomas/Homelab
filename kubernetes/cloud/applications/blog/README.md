# Ghost blog

Ghost runs as a single `Deployment` in the `ghost` namespace. Content and the SQLite database are stored on the `ghost-pvc` NFS volume. Secrets come from OCI Vault through External Secrets. Public traffic uses `blog.z3cyber.tech`; the admin route is protected by the gateway OIDC policy.

A daily backup runs at 02:00 UTC. It scales Ghost down, backs up the content PVC to the `ghost-backups` Cloudflare R2 bucket with restic, keeps seven daily snapshots, checks the repository, and restores the original replica count. A recovery CronJob runs every ten minutes and brings Ghost back if the backup pod disappears after scaling it down.

The existing OCI Vault key `oci-r2-creds` supplies `ACCESS_KEY_ID` and `ACCESS_SECRET_KEY`. Add `ghost-restic-password` to the existing `oci-ghost-secret` object. The backup reads the R2 credentials from a namespace-local ExternalSecret and the restic password from the existing `ghost-secret`.

## Install

From the repository root:

```bash
export K=zaza-oke-cluster
kubectl --context "$K" kustomize --enable-helm kubernetes/cloud/applications/blog \
  | kubectl --context "$K" apply --server-side -f -
```

Verify the deployment and route:

```bash
kubectl --context "$K" -n ghost rollout status deploy/ghost
kubectl --context "$K" -n ghost get externalsecret,pvc,httproute
curl -I https://blog.z3cyber.tech
```

## Upgrade

1. Back up the Ghost content volume, including `content/data/ghost.db`.
2. Change the image tag in `ghost-deployment.yaml` and review the Ghost migration notes for the target version.
3. Render and apply the directory with the install command above.
4. Wait for `deploy/ghost` to roll out and check the pod logs for database or migration errors.
5. Test the public site and the authenticated admin route.

## Backup

The backup workload is included in this kustomization. After confirming that `ghost-secret` contains `ghost-restic-password`, check the CronJobs and run a one-off backup:

```bash
kubectl --context "$K" -n ghost get cronjob
kubectl --context "$K" -n ghost create job --from=cronjob/ghost-backup ghost-backup-manual
kubectl --context "$K" -n ghost logs -f job/ghost-backup-manual -c backup
```

The backup repository is initialized automatically on its first successful connection. The recovery CronJob only acts when the backup marker is present, so it does not restart a deployment that was intentionally scaled to zero.

## Restore

Use `latest` or a snapshot ID from the backup logs. Stop Ghost before restoring because the PVC is restored in place:

```bash
export K=zaza-oke-cluster
SNAPSHOT=latest
JOB=ghost-restore-$(date +%s)

kubectl --context "$K" -n ghost scale deployment/ghost --replicas=0
kubectl --context "$K" -n ghost wait --for=delete pod -l app=ghost --timeout=5m

kubectl --context "$K" apply -f - <<YAML
apiVersion: batch/v1
kind: Job
metadata:
  name: $JOB
  namespace: ghost
spec:
  backoffLimit: 0
  activeDeadlineSeconds: 600
  template:
    spec:
      restartPolicy: Never
      securityContext:
        runAsNonRoot: true
        runAsUser: 65534
        runAsGroup: 65534
        fsGroup: 65534
      containers:
        - name: restore
          image: docker.io/restic/restic:0.17.3
          command: ["/bin/sh", "-ec"]
          args:
            - |
              restic restore "\$SNAPSHOT" --target /restore
              rm -rf /source/* /source/.[!.]* /source/..?* 2>/dev/null || true
              cp -a /restore/source/. /source/
          env:
            - name: SNAPSHOT
              value: "$SNAPSHOT"
            - name: RESTIC_REPOSITORY
              value: s3:https://d4f626e53977981652bb18a0948b046c.r2.cloudflarestorage.com/ghost-backups
            - name: RESTIC_PASSWORD_FILE
              value: /run/secrets/restic/ghost-restic-password
            - name: RESTIC_CACHE_DIR
              value: /tmp/restic-cache
            - name: AWS_DEFAULT_REGION
              value: auto
            - name: AWS_ACCESS_KEY_ID
              valueFrom:
                secretKeyRef:
                  name: ghost-r2-creds
                  key: ACCESS_KEY_ID
            - name: AWS_SECRET_ACCESS_KEY
              valueFrom:
                secretKeyRef:
                  name: ghost-r2-creds
                  key: ACCESS_SECRET_KEY
          volumeMounts:
            - name: ghost-content
              mountPath: /source
            - name: restore
              mountPath: /restore
            - name: restic-password
              mountPath: /run/secrets/restic
              readOnly: true
      volumes:
        - name: ghost-content
          persistentVolumeClaim:
            claimName: ghost-pvc
        - name: restore
          emptyDir: {}
        - name: restic-password
          secret:
            secretName: ghost-secret
            items:
              - key: ghost-restic-password
                path: ghost-restic-password
            defaultMode: 0400
YAML

kubectl --context "$K" -n ghost wait --for=condition=complete "job/$JOB" --timeout=10m
kubectl --context "$K" -n ghost logs "job/$JOB"
kubectl --context "$K" -n ghost delete job "$JOB"
kubectl --context "$K" -n ghost scale deployment/ghost --replicas=1
kubectl --context "$K" -n ghost rollout status deployment/ghost --timeout=5m
```

If the restore Job fails, scale Ghost back up manually after investigating:

```bash
kubectl --context "$K" -n ghost scale deployment/ghost --replicas=1
```

Keep the previous image tag until the new pod and the database have been verified. Commit and push the change so Argo CD does not revert it.
