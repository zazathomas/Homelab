# Teleport Setup Guide

## Installation

1. **Deploy the Virtual Machine (VM)**  
   - Deploy a VM with Tailscale installed to avoid exposing the VM to the public internet.
   - Set up a local DNS record for the Teleport subdomain.

2. **Install Teleport**  
   - Run the following commands to install Teleport (open-source edition):
   ```bash
   TELEPORT_EDITION="oss"
   TELEPORT_VERSION="16.4.0"
   curl https://cdn.teleport.dev/install-v16.4.0.sh | bash -s ${TELEPORT_VERSION?} ${TELEPORT_EDITION?}
   ```
   - Copy your SSL certificates (`fullchain.pem` and `privkey.pem`) to the `/var/lib/teleport` directory:
     - `fullchain.pem` (certificate)
     - `privkey.pem` (private key)

3. **Configure Teleport**  
   - Use the following command to configure Teleport, replacing the placeholders with your actual cluster name and public address:
   ```bash
   sudo teleport configure -o file \
       --cluster-name=tele.example.com \
       --public-addr=tele.example.com:443 \
       --cert-file=/var/lib/teleport/fullchain.pem \
       --key-file=/var/lib/teleport/privkey.pem
   ```

4. **Start Teleport**  
   - Enable and start the Teleport service:
   ```bash
   sudo systemctl enable teleport
   sudo systemctl start teleport
   ```
   - Check the status of the Teleport service:
   ```bash
   sudo systemctl status teleport
   ```

5. **Create a New User with 2FA**  
   - Add a new user and configure two-factor authentication (2FA):
   ```bash
   tctl users add teleport-admin --roles=editor,access --logins=root,ubuntu,ec2-user
   ```
   - Follow the URL in the terminal to complete user setup, set a password, and configure 2FA using an authenticator app.

## Exposing Teleport via Cilium API Gateway

1. **Set Up Public Routing**  
   - Use the Cilium API gateway to create a public route for Teleport.
   - Create an API Gateway *Endpoint* resource that maps to the private IP of the Teleport server (since the Kubernetes cluster is in the same subnet as the VM).

2. **Create Kubernetes Service and TLSRoute**  
   - Create a Kubernetes Service resource for Teleport.
   - Create a Teleport TLSRoute with `tlsPassthrough`, configured to listen for both `teleport.com` and `*.teleport.com` subdomains.

3. **Update DNS**  
   - Update the DNS records to point to the Cilium API gateway load balancer for public access.

4. **Configure Firewall Rules**  
   - Restrict access to Teleport by updating your security group firewall rules to allow access only from your specific IP address.

## Docker Integration with Teleport

1. **Access Docker Services via Teleport**  
   - Install Tailscale on the Docker host VM to connect it securely with the Teleport server.
   - Teleport will be able to reach all Docker services running on the VM by using the Tailscale IP and corresponding port numbers.

2. **Configure App Service**  
   - In Teleport’s configuration (`teleport.yaml`), update the `app_service` section to expose the Docker services accordingly.

By following this setup, you will have a highly available and secure Teleport instance, with private and public access configured through Tailscale and Cilium, as well as Docker integration for service access across different hosts.