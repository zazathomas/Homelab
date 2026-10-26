# Cilium

Cilium provides networking, policy enforcement, and observability for the cloud cluster. It runs in `kube-system` and is configured by `cilium-values-cloud.yaml` and `cilium-values-monitoring.yaml`.

Current Helm chart version: `1.20.4`.

## Install

From the repository root:

```bash
export K=zaza-oke-cluster
kubectl --context "$K" kustomize --enable-helm kubernetes/cloud/applications/cilium \
  | kubectl --context "$K" apply --server-side -f -
```

Verify Cilium:

```bash
cilium status --context "$K" --wait
kubectl --context "$K" -n kube-system get pods -l k8s-app=cilium
```

Run the connectivity test only when the cluster can tolerate its temporary test resources:

```bash
cilium connectivity test --context "$K"
```

## Upgrade

1. Review the Cilium release notes and compatibility with the Kubernetes server version.
2. Update the chart version and review both values files for deprecated options.
3. Render and apply the directory with the install command above.
4. Wait for the Cilium DaemonSet and operator to roll out on every node.
5. Run `cilium status --wait`, inspect policy and Gateway traffic, then run the connectivity test.

Keep the cluster network path available during the rollout. Do not remove the existing CNI until the replacement pods are ready.
