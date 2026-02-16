### Management Operations

- View installed version - > `vault -version`
- View status - > `vault status` # set VAULT_SKIP_VERIFY env variable to true or add -tls-skip-verify to the command to avoid ssl errors
- Initialize vault server - > `vault operator init -key-shares=5 -key-threshold=3` # Keep keys & root token safe
- Unseal server(Repeat command for the number of unseal keys required) - > `vault operator unseal key-1`

Execute these commands if running from a remote client:
- `export VAULT_ADDR="https://servername:8200"`
- `export VAULT_SKIP_VERIFY=true`

Login to vault after unsealing - > `vault login` # Provide root token when prompted


### Secret Engine Operations
- Create kv secret engine - > `vault secrets enable -path=kv kv`
- Create a secret - > `vault kv put kv/secret/mon-secret password="Un3T4ss32Kafé"`
- Retrieve a particular secret - > `vault kv get kv/secret/mon-secret`
- Migrate kv to kv2 - > `vault kv enable-versioning kv/`
- List existing secrets in the path - > `vault kv list kv/secret`


- Create kv-v2 secret engine - > `vault secrets enable -path=kv2 -version=2 kv`
- Create secret from json - > `vault kv put kv2/db/dev @db.json`
- Create secret in multiple key-values in kv-v2 - > `vault kv put kv2/db/dev user="app01" password="Un3T4ss32Kafé" dbname="db01"`
- Modify existing secret - > `vault kv patch kv2/db/dev ip="192.168.1.123"`
- View previous secret version - > `vault kv get -version=1 kv2/db/dev`
- Revert to previous secret version - > `vault kv rollback -version=1 kv2/db/dev`

To delete a secret, I can do it in 2 ways:
- `vault kv delete` to logically delete it (data is still present, but the secret is marked as inaccessible), vault kv undelete allows to restore it.
- `vault destroy` to permanently delete a secret (metadata is still present, but the data is deleted).

- View metadata - > `vault kv metadata get kv2/db/dev`

### Vault Authentication
There are many authentication methods, but the most common ones are:
Token (default)
LDAP
GitHub
Kubernetes
Kerberos
Userpass

- Enable userpass authentication - > `vault auth enable userpass`
- Create a user - > `vault write auth/userpass/users/username password="password"`
- Retrieve user token via http api - > `$ curl -s --request POST --data '{"password": "password"}' https://servername:8200/v1/auth/userpass/login/username | jq -r .auth.client_token`
- Enable GitHub authentication - > `vault auth enable github && vault write auth/github/config organization=your-org`
- Login via GH - > `vault login -method=github token="$(gh auth token)"`


### User Management
- Entity - > Object that represents a user/application, can be associated with a group, policy, metadata & alias
- Aliases - > Link between an entity and an authentication method
- Policy - > Defines the permissions of an entity

- List Entities - > `vault list identity/entity/name`
- Create entity - > `vault write identity/entity name="First Last" metadata=organization="Org" metadata=team="DevSecOps"`
- Delete Entity -> `vault delete identity/entity/name/entity_526e8698`
- Create groups - > `vault write identity/group name="name" policies="policy-name"`

- Attach users to groups :
To do this, create a JSON file group.json that will contain the entities of the group.
```
// group.json
{
  "member_entity_ids": [
    "16dcc20e-e718-04a2-3b9a-f811b57912c9",
    "c6b72e53-fc29-8ec4-eaca-b526c8783319"
  ]
}

example_group_id=$(vault read -format=json identity/group/name/group-name | jq -r ".data.id")
curl \
    --header "X-Vault-Token: sample-token" \
    --request POST \
    --data @group.json \
    https://servername:8200/v1/identity/group/id/${example_group_id}
```

Policy Sample - > .hcl
```
path "kv2/data/cuistops/*" {
  capabilities = ["create", "read", "update", "delete"]
}

path "kv2/metadata/cuistops/" {
  capabilities = ["list"]
}

path "kv2/data/sre/*" {
  capabilities = ["read"]
}

path "kv2/metadata/sre/" {
  capabilities = ["list"]
}
```

- Apply policy - > `vault policy write policy-name policy.hcl`



Reference: https://a-cup-of.coffee/blog/vault/, https://itnext.io/managing-kubernetes-secrets-dynamically-from-vault-via-external-secrets-operator-7e51d71b56cf