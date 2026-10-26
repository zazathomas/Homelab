# llama.cpp Qwen inference

This directory deploys a single NVIDIA-backed `llama.cpp` server in the `ai-inference` namespace.

## Current configuration

- Model: `Qwen3.5-9B-UD-Q6_K_XL.gguf`
- Model object: `s3://ai-models/unsloth/Qwen3.5-9B-GGUF/Qwen3.5-9B-UD-Q6_K_XL.gguf`
- Object-store endpoint: `https://api-s3.local.z3cyber.tech`
- Model cache PVC: `qwen-model-cache`, `16Gi`
- Service: `qwen:8080`
- Public hostname: `qwen.k8s.z3cyber.tech`
- Gateway: `envoy-gw` in `envoy-gateway-system`
- GPU request: one NVIDIA GPU
- Cache types: `q8_0` for keys and values

The `fetch-model` init container reads `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` from the `rustfs-creds` Secret. That Secret is produced by the `llama-cpp-creds` ExternalSecret from OCI Vault.

## Install and verify

```bash
export K=zaza-oke-cluster
kubectl --context "$K" apply --server-side -k kubernetes/homelab/applications/llama-cpp
kubectl --context "$K" -n ai-inference rollout status deploy/qwen
kubectl --context "$K" -n ai-inference get pvc,externalsecret,httproute
```

The pod requires a node labelled `nvidia.com/gpu.present=true` and the `nvidia` runtime class. The deployment uses `Recreate` because the model PVC is `ReadWriteOnce`.

## Files

- `qwen-deployment.yaml` — model download init container, llama.cpp server, and Service.
- `models-pvc.yaml` — model cache PVC.
- `rustfs-creds.yaml` — OCI Vault-backed ExternalSecret.
- `qwen-httproute.yaml` — Gateway API route.
- `servicemonitor.yaml` — Prometheus scrape configuration.
