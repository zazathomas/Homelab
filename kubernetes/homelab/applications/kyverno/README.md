# Kyverno values

This directory currently contains only `values.yaml`. It is not a complete Kyverno application and has no `kustomization.yaml` or deployable resource list.

The values file is retained for a future Helm deployment. Do not treat this directory as an installed or managed Kyverno release. Before deploying it, add a pinned chart reference and a kustomization, then document the target namespace, CRD ownership, policies, and verification commands.
