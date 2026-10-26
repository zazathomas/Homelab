# Vault notes

This directory contains operational notes only; it does not deploy Vault. The active Kubernetes secret flow uses External Secrets Operator with the `oci-vault-secretstore` ClusterSecretStore and OCI Vault as the source.

## Safety

Do not put Vault tokens, unseal keys, passwords, private keys, or decoded Kubernetes Secret data in this repository. Use placeholders in examples and keep real values in a password manager or Vault.

## Useful commands

Set the address for a remote Vault server:

```bash
export VAULT_ADDR="https://vault.example.invalid:8200"
```

Check status and authenticate through the configured method:

```bash
vault status
vault login
```

For KV v2, use a non-production example path and provide values interactively or through a protected file:

```bash
vault secrets enable -path=kv2 -version=2 kv
vault kv put kv2/example @example.json
vault kv get kv2/example
vault kv metadata get kv2/example
```

Delete or destroy data only after confirming the recovery requirements:

```bash
vault kv delete kv2/example
vault kv destroy -versions=1 kv2/example
```

## Kubernetes integration

The ClusterSecretStore and OCI authentication resources are managed outside this directory. When troubleshooting an ExternalSecret, check the store first, then inspect only status and conditions:

```bash
kubectl get clustersecretstore oci-vault-secretstore
kubectl get externalsecret -A
```

Never print Secret data while troubleshooting.
