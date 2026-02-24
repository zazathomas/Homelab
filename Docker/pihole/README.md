
# Pi-hole + Unbound Deployment Guide (Docker Compose + Keepalived HA)

This guide explains how to deploy **Pi-hole with Unbound** using Docker Compose, with optional **Keepalived** for high availability (HA).  
The setup provides:

- Network-wide ad blocking (Pi-hole)
- Recursive DNS resolution (Unbound)
- High availability with a virtual IP (Keepalived)
- Docker-based deployment
- Persistent configuration

This setup is designed for Debian/Ubuntu systems but can be adapted to others.

---

# Architecture Overview

```

Clients
│
│ DNS (Port 53)
▼
Virtual IP (Keepalived)
│
├── Primary Node
│     ├── Pi-hole (Port 53)
│     └── Unbound (Port 5353)
│
└── Secondary Node
├── Pi-hole (Port 53)
└── Unbound (Port 5353)

````

Pi-hole handles DNS requests and forwards them to Unbound for recursive resolution.

---

# Prerequisites

## System Requirements

- Ubuntu or Debian
- Docker
- Docker Compose
- Root or sudo access
- Static IP address
- Two nodes (for HA)

Example:

| Node | IP |
|------|----|
| Primary | 192.168.0.3 |
| Secondary | 192.168.0.4 |
| Virtual IP | 192.168.0.2 |

---

# 1. Install Dependencies

Update system:

```bash
sudo apt update
sudo apt upgrade -y
````

Install Docker:

```bash
sudo apt install -y docker.io docker-compose-plugin
sudo systemctl enable docker
sudo systemctl start docker
```

Install Keepalived:

```bash
sudo apt install -y keepalived
```

---

# 2. Disable systemd DNS Stub Listener

Pi-hole needs port 53, so disable the system resolver stub.

Edit:

```bash
sudo nano /etc/systemd/resolved.conf
```

Change:

```
#DNSStubListener=yes
```

To:

```
DNSStubListener=no
```

Apply changes:

```bash
sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
sudo systemctl restart systemd-resolved
```

Verify port 53 is free:

```bash
sudo ss -tulpn | grep :53
```

You should see nothing listening on port 53.

---

# 3. Create Project Structure

Create directories:

```bash
mkdir -p ~/pihole-stack
cd ~/pihole-stack

mkdir pihole
mkdir unbound
```

Structure:

```
pihole-stack/
 ├── compose.yaml
 ├── .env
 ├── pihole/
 └── unbound/
```

---

# 4. Configure Unbound

Create Unbound config directory:

```bash
mkdir -p unbound
```

Copy your Unbound config:

```bash
cp pi-hole.conf ./unbound/
```

Example `pi-hole.conf`:

```
server:
  verbosity: 1
  interface: 0.0.0.0
  port: 53
  do-ip4: yes
  do-udp: yes
  do-tcp: yes
  root-hints: "/var/lib/unbound/root.hints"
  hide-identity: yes
  hide-version: yes
```

---

# 5. Create Environment File

Create `.env`:

```bash
nano .env
```

Add:

```
WEBPASSWORD=your-password
TZ=Europe/Dublin
```

---

# 6. Create Docker Compose File

Create `compose.yaml`:

```yaml
services:
  pihole:
    container_name: pihole
    hostname: pihole
    image: docker.io/pihole/pihole:2026.02.0
    ports:
      - 53:53/tcp
      - 53:53/udp
      - 80:80/tcp
    environment:
      TZ: Europe/Dublin
      FTLCONF_dns_listeningMode: "ALL"
      FTLCONF_dns_upstreams: "unbound#53"
      FTLCONF_webserver_api_password: ${WEBPASSWORD}
      FTLCONF_dns_dnssec: "true"
      PUID: "1000"
      PGID: "1000"
    env_file: .env
    volumes:
      - "./pihole:/etc/pihole"
    restart: unless-stopped
    depends_on:
      - unbound

  unbound:
    container_name: unbound
    image: mvance/unbound:latest
    ports:
      - "5353:53/tcp"
      - "5353:53/udp"
    volumes:
      - "./unbound:/etc/unbound/custom.conf.d"
    restart: unless-stopped
```

---

# 7. Start Pi-hole + Unbound

Start containers:

```bash
docker compose up -d --force-recreate
```

Check containers:

```bash
docker ps
```

---

# 8. Access Pi-hole

Open browser:

```
http://SERVER-IP/admin
```

Login with password from `.env`.

---

# 9. Configure Keepalived (Primary Node)

Edit:

```bash
sudo nano /etc/keepalived/keepalived.conf
```

Primary configuration:

```
global_defs {
    router_id MASTER_NODE
}

vrrp_sync_group VG1 {
    group {
        VI_192_168_0_0
        VI_10_0_0_0
    }
}

vrrp_instance VI_192_168_0_0 {
    state MASTER
    interface eth0
    virtual_router_id 51
    priority 101
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass your-pass
    }
    unicast_peer {
        192.168.0.4
    }
    virtual_ipaddress {
        192.168.0.2/24
    }
}

vrrp_instance VI_10_0_0_0 {
    state MASTER
    interface eth1
    virtual_router_id 52
    priority 101
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass your-pass
    }
    unicast_peer {
        10.0.0.4
    }
    virtual_ipaddress {
        10.0.0.2/24
    }
}
```

---

# 10. Configure Keepalived (Backup Node)

Edit:

```bash
sudo nano /etc/keepalived/keepalived.conf
```

Backup configuration:

```
global_defs {
    router_id BACKUP_NODE
}

vrrp_sync_group VG1 {
    group {
        VI_192_168_0_0
    }
}

vrrp_instance VI_192_168_0_0 {
    state BACKUP
    interface eth0
    virtual_router_id 51
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass your-pass
    }
    unicast_peer {
        192.168.0.3
    }
    virtual_ipaddress {
        192.168.0.2/24
    }
}
```

---

# 11. Start Keepalived

Enable service:

```bash
sudo systemctl enable keepalived
sudo systemctl start keepalived
```

Check status:

```bash
sudo systemctl status keepalived
```

---

# 12. Verify Virtual IP

Check IP address:

```bash
ip a
```

You should see:

```
192.168.0.2
```

---

# 13. Test Failover

Stop Keepalived on master:

```bash
sudo systemctl stop keepalived
```

Verify VIP moves to backup node.

---

# 14. Configure Router

Set DNS server to:

```
192.168.0.2
```

---

# 15. Test DNS

Test resolution:

```bash
nslookup google.com 192.168.0.2
```

---

# 16. Maintenance

Update containers:

```bash
docker compose pull
docker compose up -d
```

---

# 17. Troubleshooting

## Port 53 in Use

Check:

```bash
sudo ss -tulpn | grep :53
```

Stop conflicting services.

---

## Containers Not Starting

Check logs:

```bash
docker logs pihole
docker logs unbound
```

---

## Keepalived Not Working

Check:

```bash
sudo journalctl -u keepalived
```

---

# 18. Backup

Backup config:

```bash
tar czf pihole-backup.tar.gz pihole unbound compose.yaml .env
```

---

# 19. Restore

Extract:

```bash
tar xzf pihole-backup.tar.gz
docker compose up -d
```

---

# Deployment Complete

You now have:

* Pi-hole DNS filtering
* Unbound recursive DNS
* High availability VIP
* Docker deployment

Your DNS server is available at:

```
192.168.0.2
```
