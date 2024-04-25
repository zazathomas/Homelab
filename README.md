# Homelab @ 127.0.0.1

Welcome to my homelab repository, a well crafted digital ecosystem designed to showcase the convergence of computing and security. Here I've implemented a virtual playground where I get to try out different projects.

<img width="1779" alt="Screenshot 2024-04-25 at 01 22 13" src="https://github.com/zazathomas/Homelab/assets/21116259/b58793e2-ed71-4a32-ae9d-44c320043cdb">



Starting of on this repository, I've implemented a DevSecOps pipeline for secrets and IaC scanning using Trufflehog and Checkov respectively. This ensure the security and reliability of my homelab infrastructure.

I bootstrapped this cluster using a shell script. More details ...
I swapped out flannel for Cilium because Why not?!
This simplified the bootstrapping of a resilient Kubernetes cluster.

Core Services
Explore the essential services currently deployed in my homelab:

- Proxmox: A powerful hypervisor orchestrating the virtual landscape.
- Adguard: Providing local DNS and adblocking for enhanced privacy and security.
- Traefik: Serving as a reliable reverse proxy to safeguard access to homelab services.
- Cert-manager: Managing certificates to ensure secure communications within the cluster.
- Prometheus and Grafana: Monitoring system health and performance comprehensively.
- Loki and Promtail: Capturing and analyzing logs for deeper insights.
- Tetragon: Enhancing security with comprehensive runtime protection.
- Homarr: Offering insightful metrics and analytics through a homelab dashboard.
- Sealed-secrets: Encrypting sensitive data securely to protect secrets.
- DIUN: Ensuring timely patch management and updates across the homelab environment.

Join the Quest
Embark on a journey through the realms of technology and security. Explore the intricacies of my homelab repository—a testament to modern infrastructure management and security practices. Welcome to an adventure of discovery and innovation.










