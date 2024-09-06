# Deploying K3s with Cilium CNI

The purpose of this shell script is to deploy A K3S Cluster using Cilium while disabling Flannel as the default CNI. This is because of the many advantages ebpf based solutions provide to networking in K8s. An added advantage to Cilium is that we don't have to use Metallb anymore as a loadbalancer service. Cilium now has built in support for L2 advertisement.

To use this script, copy over all files in this directory to your local machine, modify the start and stop ranges in the IpAddressPool.yaml file to match your ip pool. Modify the Cilium values.yaml file if you'd like but the default settings I configured should work straight out the box.

Modify the Ip addresses in the deploy.sh script to match your master and worker nodes.

Copy over your private key for the master and worker nodes to this directory and rename to id_rsa if not already named that. 
Modify the cluster name variable as required. 
Modify the user as required for the master and worker nodes.
Modify the network interface if it is different from eth0

