<div align="center">

![image](https://github.com/zazathomas/Homelab/assets/21116259/2f210bf0-33c2-4972-b8da-728c82ce608f)


# 🌐 K3S+Cilium Homelab 🏡

</div>

---

## 📝 Overview

This is the [IaC](https://github.com/zazathomas/Homelab/tree/main/Infrastructure/OracleCloud/Terraform) configuration for my homelab.
It's mainly powered by [Kubernetes](https://kubernetes.io/) and I do my best to adhere to GitOps practices.

To organise all the configuration I've opted for an approach using a combination of yaml manifests & Helm with Argo CD for streamlined deployment.

I plan to journal my adventures and exploits on my [GitHub](https://github.com/zazathomas/Homelab).

## ☸ Architecture

<img width="1626" alt="Screenshot 2024-05-02 at 12 48 22" src="https://github.com/zazathomas/Homelab/assets/21116259/1fcd4aff-6001-42df-85ed-8b183087d17b">

## 🧑‍💻 Getting Started

If you're new to Kubernetes I've written a shell script for [Bootstrapping k3s with Cilium](https://github.com/zazathomas/Homelab/tree/main/K8s/K3s%2BCilium).

Starting of on this repository, I've implemented a DevSecOps pipeline for secrets and IaC scanning using Trufflehog and Checkov respectively. This ensures the security and reliability of my homelab infrastructure.

## ⚙️ Core Components

- [Argo CD](https://argo-cd.readthedocs.io/en/stable/): Declarative, GitOps continuous delivery tool for Kubernetes.
- [Cilium](https://cilium.io/): eBPF-based Networking, Observability, Security.
- [Teleport](https://goteleport.com/docs): Identity aware proxy to manage access for Servers, DBs, K8S clusters etc.
- [OpenTofu](https://opentofu.org/): The open source infrastructure as code tool.
- [Sealed-secrets](https://github.com/bitnami-labs/sealed-secrets): Encrypt your Secret into a SealedSecret, which is
  safe to store - even inside a public repository.
- [Proxmox](https://www.proxmox.com/en): A powerful type-1 hypervisor orchestrating the virtual landscape.
- [Adguard](https://github.com/AdguardTeam/AdGuardHome): Local DNS and adblocking for enhanced privacy and security.
- [Traefik](https://doc.traefik.io/traefik/): This is a reliable cloud-native reverse proxy to safeguard access to homelab services.
- [Cert-manager](https://cert-manager.io/docs/): Managing certificates to ensure secure communications within & Outside the cluster.
- [Kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack): Stack consisting of Prometheus, Grafana and NodeExporter for monitoring metrics and performance comprehensively.
- [Loki & Promtail](https://grafana.com/oss/loki/): Log aggregation stack for getting deeper insights into the state of various resources.
- [Tetragon](https://tetragon.io/): eBPF based runtime security tool with comprehensive protection features.
- [Homarr](https://homarr.dev/docs/getting-started/installation/): Homelab dashboard offering insightful metrics and analytics through a user friendly UI.
- [DIUN](https://crazymax.dev/diun/): Ensuring timely patch management and updates across the homelab environment.
- [Tailscale](https://tailscale.com/kb/1151/what-is-tailscale): IPSec Wireguard VPN that powers the connection between my On-prem resources and Oracle Cloud.
- [Wazuh](https://documentation.wazuh.com/current/index.html): Feature rich opensource SIEM and XDR solution.

## 📂 Folder Structure

* `infrastructure`: Configuration for core infrastructure components
* `Infrastructure/OracleCloud`: OpenTofu/Terraform configuration for my Oracle cloud infrastructure.
* `K8s`: Holds my Helm/yaml manifests.

## 🖥️ Hardware

| Name   | Device                    | CPU             | RAM            | Storage    |  Location    |
|--------|---------------------------|-----------------|----------------|------------|--------------|
| my-promox-host   |HP Mini G3-800 | Intel Core i5 | 32 GB DDR4  | 1 TiB SSD | 127.0.0.1 |
| Docker-host | VM    | Arm     | 16 GB DDR4     | 50GB | Oracle Cloud |

## 🏗️ Work in Progress
- [ ] Deploy Wazuh for my SIEM solution.
- [ ] Deploy Teleport for Access Management.
- [ ] Deploy Vault, Vaultwarden & Kyverno.
- [ ] Setup Infra Node(Terraform,Ansible&Packer) on proxmox via LXC.

## 👷‍ Future Projects

- [ ] Keycloak for auth
- [ ] Replace nfs storage with block storage.
- [ ] Add Pi Hole as a backup DNS server 
- [ ] Setup Cilium mTLS & SPIFFE/SPIRE

