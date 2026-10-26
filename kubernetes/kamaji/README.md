# Kamaji workload cluster

This directory contains the Kamaji workload-control-plane template and the worker-node bootstrap script used for the hybrid cluster experiment. It is not a Kustomize application and is not installed by the cloud or homelab application sets.

## Current template

`tcp-template.yaml` defines a `TenantControlPlane` named `homelab-hosted-cp` with:

- Kubernetes `v1.31.4`
- One control-plane replica
- A LoadBalancer service with an OCI NLB annotation
- `systemd` cgroups and InternalIP kubelet addressing
- CoreDNS, kube-proxy, and Konnectivity

Review and change the control-plane endpoint and network profile before applying it to a cluster. The template currently leaves the optional address and certificate SAN examples commented out.

## Prerequisites

- A Kamaji management cluster with the Kamaji CRDs and controller installed.
- cert-manager and the required Kamaji certificates.
- `kubectl`, `kubeadm`, and access to the management cluster.
- Ubuntu worker VMs with compatible kernel, container runtime, and network access.

The repository does not contain the Kamaji Helm release configuration. Install Kamaji and cert-manager according to the versions supported by the management cluster, then apply the tenant template:

```bash
kubectl apply -f kubernetes/kamaji/tcp-template.yaml
kubectl get tenantcontrolplane homelab-hosted-cp
```

## Worker bootstrap

`yaki.sh` is a local copy of the worker bootstrap helper. Read its usage output before running it:

```bash
sudo bash kubernetes/kamaji/yaki.sh help
```

The script requires root privileges. Set `KUBERNETES_VERSION` to the same version as the tenant control plane and supply join variables only through the environment or a protected shell session. Never commit join tokens or certificate keys.

Example bootstrap command:

```bash
sudo KUBERNETES_VERSION=v1.31.4 \
  bash kubernetes/kamaji/yaki.sh bootstrap
```

## Cilium values

`tcp-cilium-values.yaml` is a reference values file for a workload cluster. Replace the placeholder `k8sServiceHost` and review the pod CIDR, Gateway API, encryption, Hubble, and SPIRE settings before installing Cilium.

## Kamaji console

`console-values.yaml` is a reference values file. It deliberately leaves `credentialsSecret.generate` disabled and does not contain console credentials. Create the referenced Secret outside the repository before installing the console.
