# Extending my Homelab to the cloud via Oracle Always free tier.
The aim of this exercise is to provision a functional homelab environment within the limits of the always free tier.
- Resources to be deployed: 4 VMs, 1 Flexible Load balancer, 3 Subnets, 3 Security Groups, 2 Route Tables, 1 Internet Gateway, 1 NAT Gateway, & 1 VCN.
### Oracle Cloud Setup: Provision Resources on Oracle Cloud
- Create a VPC / CIDR 172.16.0.0/16.
- Create an edge public subnet / CIDR 172.16.1.0/24.
- Create a private subnet / CIDR 172.16.2.0/24.
- Create a lb public subnet / CIDR 172.16.3.0/24.
- Create an IGW and NATGW.
- Create 4 VMs, 1 in the public edge subnet & 3 in the private subnet.
- Create a Route table with rule => 0.0.0.0/0 with target of IGW and attach it to public subnet.
- Create a Route table with rule => 0.0.0.0/0 with target of NATGW and attach it to private subnet.
- Add a route in the route table of the private subnet for 192.168.0.0/24(LAN Subnet) via the VGW Private IP.
- Create a public security group that allows inbound SSH traffic and outbound traffic to the internet 0.0.0.0/0.
- Create a lb security group that allows inbound traffic from the internet, outbound traffic to the internet 0.0.0.0/0 & outbound traffic to the private subnet.
- Create a private security group that allows inbound SSH traffic from the VCN CIDR(172.16.0.0/16) and allow inbound from the lb sg and outbound traffic to the internet 0.0.0.0/0.
- Create a Flexible public lb.
- Create teleport-backend-set & add the teleport instance using port 443.
- Create teleport-listener with TCP protocol and 443 port & attach the teleport backend set to this.
---

### Site-2-Site VPN Tailscale setup On the Oracle Cloud Side
Flush all iptable rules and then proceed:

Install tailscale in this case for Ubuntu 22.04:
```
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list
sudo apt-get update
sudo apt-get install tailscale
```
#### enable port-forwarding
```
echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
sudo sysctl -p /etc/sysctl.d/99-tailscale.conf
sudo systemctl enable --now tailscaled
sudo tailscale up --advertise-routes=172.16.1.0/24,172.16.2.0/24 --snat-subnet-routes=false --accept-routes=true --stateful-filtering=false --advertise-exit-node 
```

#### Follow the link to add the device to your tailnet and then Visit the Tailscale admin console and perform the following actions:
1) Disable key expiry on the subnet router so that you don't need to reauthenticate the server periodically.
2) Authorize subnet routes on the device, so that Tailscale distributes the 172.16.1.0/24 and 172.16.2.0/24 routes to the rest of your Tailscale network.

### Tailscale setup On the LAN side
I installed tailscale using an Ubuntu LXc container on proxmox so I had to jump through a few extra hops i.e. Run tailscale in lxc https://tailscale.com/kb/1130/lxc-unprivileged.
Other that this minor detour, follow the exact same steps to install and setup tailscale while changing the route advertised to match the CIDR of your LAN in my case 192.168.0.0/24. i.e.

`sudo tailscale up --advertise-routes=192.168.0.0/24 --snat-subnet-routes=false --accept-routes=true --stateful-filtering=false --advertise-exit-node`. 

After the setup is done, you need to add a route on your router(if you're lucky enough to have anything but a basic ISP router) for the Oracle cloud VCN CIDR i.e. 172.16.0.0/16
For we the unlucky few, Manually add static routes on each device that needs to access the Cloud environment: ip route add {NETWORK/MASK} via {GATEWAYIP} i.e. 

`sudo ip route add 172.16.0.0/16 via 192.168.0.9(your on-prem tailscale IP aka CGW)`. 

Luckily i'm lazy and I can just use ansible to add this anytime I provision a new server(automation to the rescue)
Once this is all done, Check that you can ping the devices on your cloud infrastructure(private and public subnet) and vice versa.
The final step is to Edit the inbound rules of the public SG and delete the rule allowing SSH access.

If this all feels to daunting, I prepared a Terraform script that deploys all the necessary cloud infra and installs tailscale on your Router VM. I didn't include the setup on your LAN side because there could be multiple ways to deploy this. You can find here #Link. Modify as required.
Voila, you now have a have your Homelab connected to your cloud setup. I hope you have as much fun following this guide as I did writing it. Until next time... Ciao!!

#### Flush iptables
```
sudo iptables -L -v
sudo iptables -F
sudo iptables -P INPUT ACCEPT
sudo iptables -P OUTPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -P ts-input ACCEPT
sudo iptables -P ts-forward ACCEPT
sudo netfilter-persistent save
sudo systemctl disable netfilter-persistent
sudo systemctl restart networking.service
```

#### add static route mac
```
sudo route -n add -net 172.16.0.0/16 192.168.0.9
sudo route -n add -net 100.64.0.0/10 192.168.0.9
```

#### Add static routes ubuntu
```
ip route add 172.16.0.0/16 via 192.168.0.9
ip route add 100.64.0.0/10 via 192.168.0.9
```

#### Open ports on the Cloud VMs
Open the incoming ports on each VM

`iptables -I INPUT -p tcp --dport 443 -j ACCEPT`

Open the outgoing ports on each VM

`iptables -I INPUT -p tcp --dport 53 -j ACCEPT`
