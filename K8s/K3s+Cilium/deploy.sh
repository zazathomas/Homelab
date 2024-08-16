#!/bin/bash                                      
#############################################
# YOU SHOULD ONLY NEED TO EDIT THIS SECTION #
#############################################

# Cluster name
clusterName="zazas-homelab"
# K3S Version
k3sVersion="v1.30.3+k3s1"

# Set the IP addresses of the master and work nodes
master1=192.168.0.39
worker1=192.168.0.150

# User of remote machines
user=zaza

# Loadbalancer IP range
start=192.168.0.2
stop=192.168.0.10

# Interface used on remotes
interface=eth0

# Array of master nodes
masters=()

# Array of worker nodes
workers=($worker1)

# Array of all
all=($master1 $worker1)

# Array of all minus master
allnomaster1=($worker1)

#ssh certificate name variable
certName=id_rsa

#############################################
#            DO NOT EDIT BELOW              #
#############################################
# For testing purposes - in case time is wrong due to VM snapshots
sudo timedatectl set-ntp off
sudo timedatectl set-ntp on

# Change permissions on SSH key
chmod 600 $certName $certName.pub


# Move SSH certs to ~/.ssh and change permissions
cp /home/$user/{$certName,$certName.pub} /home/$user/.ssh
chmod 600 /home/$user/.ssh/$certName 
chmod 644 /home/$user/.ssh/$certName.pub

# Install k3sup to local machine if not already present
if ! command -v k3sup version &> /dev/null
then
    echo -e " \033[31;5mk3sup not found, installing\033[0m"
    curl -sLS https://get.k3sup.dev | sh
    sudo install k3sup /usr/local/bin/
else
    echo -e " \033[32;5mk3sup already installed\033[0m"
fi

# Install Kubectl if not already present
if ! command -v kubectl version &> /dev/null
then
    echo -e " \033[31;5mKubectl not found, installing\033[0m"
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
else
    echo -e " \033[32;5mKubectl already installed\033[0m"
fi

# Create SSH Config file to ignore checking (don't use in production!)
echo "StrictHostKeyChecking no" > ~/.ssh/config

#add ssh keys for all nodes
for node in "${all[@]}"; do
  ssh-copy-id $user@$node
done

# Install policycoreutils for each node
for newnode in "${all[@]}"; do
  ssh $user@$newnode -i ~/.ssh/$certName sudo su <<EOF
  NEEDRESTART_MODE=a apt install policycoreutils -y
  exit
EOF
  echo -e " \033[32;5mPolicyCoreUtils installed!\033[0m"
done

# Step 1: Bootstrap First k3s Node
mkdir ~/.kube
k3sup install \
  --ip $master1 \
  --user $user \
  --cluster \
  --k3s-extra-args "--node-taint node-role.kubernetes.io/master=true:NoSchedule --disable-kube-proxy --disable traefik --disable servicelb  --flannel-backend=none --disable-network-policy --node-ip=$master1 --kube-controller-manager-arg bind-address=0.0.0.0 --kube-proxy-arg metrics-bind-address=0.0.0.0 --kube-scheduler-arg bind-address=0.0.0.0 --etcd-expose-metrics true --kubelet-arg containerd=/run/k3s/containerd/containerd.sock" \
  --merge \
  --sudo \
  --local-path $HOME/.kube/config \
  --ssh-key $HOME/.ssh/$certName \
  --context $clusterName \
  --k3s-version $k3sVersion
echo -e " \033[32;5mFirst Node bootstrapped successfully!\033[0m"


# Step 2: Install Cilium
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz
cilium install -f values.yaml

# Step 3: add workers
for newagent in "${workers[@]}"; do
  k3sup join \
    --ip $newagent \
    --user $user \
    --sudo \
    --server-ip $master1 \
    --k3s-version $k3sVersion \
    --ssh-key $HOME/.ssh/$certName \
    --k3s-extra-args "--node-label \"worker=true\""
  echo -e " \033[32;5mAgent node joined successfully!\033[0m"
done

# Step 4: Get Cilium Status
cilium status --wait


# Step 5: Deploy IP Pool
kubectl apply -f IpAddressPool.yaml

# Step 6: Install CiliumL2AnnouncementPolicy to instruct Cilium how to do L2 announcements
kubectl apply -f annouce.yaml

# Step 7: Test the cluster
kubectl apply -f smoke-test.yaml

echo -e " \033[32;5mWaiting for K3S to sync and LoadBalancer to come online\033[0m"

while [[ $(kubectl get pods -n whoami -l app=whoami -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do
   sleep 1
done

kubectl get nodes
kubectl get svc -n whoami
kubectl get pods --all-namespaces -o wide

# Step 5: Test Cilium
echo -e " \033[32;5mTesting Cilium Connectivity\033[0m"

cilium connectivity test

echo -e " \033[32;5mHappy Kubing! Access whoami at EXTERNAL-IP above\033[0m"