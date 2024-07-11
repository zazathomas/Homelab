## Setup teleport behind a reverse proxy
- Setup dns records for your domain and request certs via cert-manager or reverse proxy directly.
- Configure reverse proxy to forward traffic to port 3080.

### Teleport.yaml config for use behind a reverse proxy

```
version: v3
teleport:
  nodename: TeleportIAP
  data_dir: /var/lib/teleport
  log:
    output: stderr
    severity: INFO
    format:
      output: text
  ca_pin: ""
  diag_addr: ""
auth_service:
  enabled: "yes"
  listen_addr: 0.0.0.0:3025
  cluster_name: "teleport.z3cyber.pro"
  proxy_listener_mode: multiplex
ssh_service:
  enabled: "yes"
  commands:
  - name: hostname
    command: [hostname]
    period: 1m0s
proxy_service:
  enabled: "yes"
  web_listen_addr: 0.0.0.0:3080
  public_addr: teleport.z3cyber.pro:443
  https_keypairs: []
  https_keypairs_reload_interval: 0s
  acme: {}
  trust_x_forwarded_for: true
  tunnel_listen_addr: 0.0.0.0:3024
  tunnel_public_addr: teleport.z3cyber.pro:3024
  peer_listen_addr: 0.0.0.0:3022
  ssh_public_addr: teleport.z3cyber.pro:3023
  kube_listen_addr: 0.0.0.0:3026
  kube_public_addr: teleport.z3cyber.pro:3026
```

Add domains to cloudflare, point to the internal ip for teleport
Use nginx proxy manager to generate certs and then copy to teleport server and start using:
sudo teleport configure -o file \
    --cluster-name=teleport.z3cyber.pro \
    --public-addr=teleport.z3cyber.pro:443 \
    --cert-file=/var/lib/teleport/fullchain.pem \
    --key-file=/var/lib/teleport/privkey.pem


### Teleport.yaml config without reverse proxy

```
version: v3
teleport:
  nodename: Teleport
  data_dir: /var/lib/teleport
  log:
    output: stderr
    severity: INFO
    format:
      output: text
  ca_pin: ""
  diag_addr: 0.0.0.0:3000
auth_service:
  enabled: "yes"
  listen_addr: 0.0.0.0:3025
  cluster_name: teleport.z3cyber.pro
  proxy_listener_mode: multiplex
ssh_service:
  enabled: "yes"
  commands:
  - name: hostname
    command: [hostname]
    period: 1m0s
proxy_service:
  enabled: "yes"
  web_listen_addr: 0.0.0.0:443
  public_addr: teleport.z3cyber.pro:443
  https_keypairs:
  - key_file: /var/lib/teleport/privkey.pem
    cert_file: /var/lib/teleport/fullchain.pem
  https_keypairs_reload_interval: 0s
  acme: {}
app_service:
    enabled: yes
    debug_app: true
    apps:
    - name: "wazuh"
      uri: "https://172.16.2.106:443"
      public_addr: "wazuh.teleport.z3cyber.pro"
      insecure_skip_verify: true
    - name: "portainer"
      uri: "https://172.16.2.189:9443"
      public_addr: "portainer.teleport.z3cyber.pro"
      insecure_skip_verify: true
```