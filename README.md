<div align="center">

![image](https://github.com/zazathomas/Homelab/assets/21116259/2f210bf0-33c2-4972-b8da-728c82ce608f)


# 🌐 K3S+Cilium Homelab 🏡

</div>

---

## 📝 Overview

This repository contains the [Infrastructure as Code (IaC)](https://github.com/zazathomas/Homelab/tree/main/Infrastructure/) configuration for my homelab. The environment is powered by a combination of Docker-based virtual machines and [Kubernetes](https://kubernetes.io/), with a strong emphasis on adhering to GitOps principles.  

To ensure a well-organized and efficient setup, I leverage a combination of YAML manifests and Helm charts, orchestrated through Argo CD for streamlined and automated deployments.  

I also plan to document my journey and share insights on my [GitHub](https://github.com/zazathomas/Homelab), showcasing the lessons learned and innovations achieved throughout this project.  



## ☸ Architecture

<img width="1626" alt="Screenshot 2024-05-02 at 12 48 22" src="https://github.com/zazathomas/Homelab/assets/21116259/1fcd4aff-6001-42df-85ed-8b183087d17b">

---

## 🧑‍💻 Getting Started  

For newcomers to Kubernetes, I have adapted an existing shell script to streamline the [Bootstrapping of k3s with Cilium](https://github.com/zazathomas/Homelab/tree/main/K8s/K3s%2BCilium). This provides a simple and efficient starting point for setting up a lightweight Kubernetes cluster.  

In this repository, I have also implemented a robust DevSecOps pipeline to enhance the security and reliability of the homelab infrastructure. This pipeline integrates **Trufflehog** for secret scanning and **Checkov** for Infrastructure as Code (IaC) security analysis, ensuring adherence to best practices and safeguarding sensitive data. 

## ⚙️ Core Components

- [Argo CD](https://argo-cd.readthedocs.io/en/stable/): A declarative, GitOps-based continuous delivery tool for Kubernetes.
- [Cilium](https://cilium.io/): A cutting-edge networking, observability, and security solution powered by eBPF.
- [Teleport](https://goteleport.com/docs): An identity-aware proxy that simplifies and secures access to servers, databases, Kubernetes clusters, and more.
- [Terraform](https://opentofu.org/): An open-source infrastructure-as-code tool for automating infrastructure deployment.
- [Sealed-secrets](https://github.com/bitnami-labs/sealed-secrets): Securely encrypt Kubernetes secrets for safe storage, even in public repositories.

- [Proxmox](https://www.proxmox.com/en): A robust type-1 hypervisor enabling efficient orchestration of virtualized environments.
- [Adguard](https://github.com/AdguardTeam/AdGuardHome): A local DNS and ad-blocking solution designed to enhance privacy and security.

- [Traefik](https://doc.traefik.io/traefik/): A cloud-native reverse proxy ensuring secure and efficient access to homelab services.
- [Cert-manager](https://cert-manager.io/docs/): An automated certificate management solution for secure communication within and outside Kubernetes clusters.
- [Kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack): A comprehensive monitoring stack that includes Prometheus, Grafana, and Node Exporter for detailed metrics and performance insights.
- [Loki & Alloy](https://grafana.com/oss/loki/): A powerful log aggregation stack offering deep insights into system states and events.
- [Tetragon](https://tetragon.io/): A runtime security tool leveraging eBPF for advanced system protection and monitoring.
- [Homepage](https://gethomepage.dev/): A modern, fully static, fast, secure fully proxied, highly customizable application dashboard with integrations for over 100 services.
- [DIUN](https://crazymax.dev/diun/): A tool for proactive patch management and image update notifications in containerized environments.
- [Tailscale](https://tailscale.com/kb/1151/what-is-tailscale): A modern VPN built on WireGuard, enabling seamless connectivity between on-premises resources and cloud environments.
- [Wazuh](https://documentation.wazuh.com/current/index.html): An open-source, feature-rich SIEM and XDR solution for comprehensive security monitoring and threat detection.
- [Jenkins](https://www.jenkins.io): A leading open-source automation server for building, testing, and deploying applications.
- [Kyverno](https://kyverno.io/): A policy engine for Kubernetes that enables dynamic policy management and governance.
- [Cilium Gateway API](https://cilium.io/use-cases/gateway-api/): A flexible, extensible API for defining routing and load-balancing configurations in Kubernetes.
- [N8n](https://n8n.io/): A powerful workflow automation tool for connecting applications and services seamlessly.
- [NGX-paperless](https://github.com/paperless-ngx/paperless-ngx): A document management system for digitizing and organizing paperwork efficiently.
- [Portainer](https://www.portainer.io/): A simple and elegant container management solution for Docker, Kubernetes, and other container platforms.
- [Keycloak](https://www.keycloak.org/): An open-source identity and access management solution providing single sign-on (SSO), identity brokering, and user federation for securing modern applications and services.
- [Minio](https://min.io/): A high-performance, distributed object storage system compatible with the Amazon S3 API, ideal for scalable cloud-native storage solutions.
- [SPIRE](https://github.com/spiffe/spire): A production-grade implementation of the SPIFFE standard for workload identity, enabling secure service-to-service authentication in distributed systems.

## 📂 Folder Structure

* `Infrastructure`: Terraform configurations for provisioning and managing core infrastructure components.
* `Docker`: Docker Compose files for orchestrating various homelab services.
* `K8s`: Helm charts and YAML manifests for Kubernetes resource definitions and management.

## 🖥️ Hardware

| Name   | Device                    | CPU             | RAM            | Storage    |  Location    |
|--------|---------------------------|-----------------|----------------|------------|--------------|
| Pve-main | Morefine S600 | Ryzen 9 | 64 GB DDR5  | 1 TiB SSD | 192.168.0.189 |
| Intel-node   |HP Mini G3-800 | Intel Core i5 | 32 GB DDR4  | 1 TiB SSD | 192.168.0.59 |
| Docker-vm | VM | AMD | 32 GB  | 0.4 TiB SSD | 192.168.0.32 |
| OKE-node-01 | VM    | ARM     | 12 GB     | 50GB | Oracle Cloud |
| OKE-node-02 | VM    | ARM     | 12 GB     | 50GB | Oracle Cloud |
| Storage-01 | VM    | Intel     | 1 GB      | 50GB | Oracle Cloud |
| Teleport | VM    | Intel     | 1 GB      | 50GB | Oracle Cloud | 

---

## 🏗️ Work in Progress 
1. **Deploy External Secrets Operator (ESO):** Implement ESO for centralized and secure secrets management within the Kubernetes ecosystem.  
2. **Deploy Harbor:** Set up Harbor as a self-hosted container registry to manage and secure container images.  
3. **Configure Tailscale Router Node:** Establish a Tailscale router node to enable Jenkins, hosted in Oracle Kubernetes Engine, to manage homelab services within the LAN.  

## 👷‍ Future Plans  
1. **Redeploy Keycloak:** Migrate Keycloak to leverage an external PostgreSQL database for enhanced scalability and reliability.  
2. **Integrate Object Storage:** Add an object storage-backed storage class to Kubernetes to enable dynamic Persistent Volume (PV) provisioning.  
3. **Deploy Pi-hole:** Configure Pi-hole as a backup DNS server to enhance network resilience and redundancy.  