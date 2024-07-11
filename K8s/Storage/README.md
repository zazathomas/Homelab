# Setup an nfs server 
```
sudo apt-get install nfs-kernel-server
sudo mkdir -p /mnt/nfs_share
sudo chown nobody:nogroup /mnt/nfs_share
sudo chmod 0777 /mnt/nfs_share
sudo mv /etc/exports /etc/exports.bak
echo '/mnt/nfs_share 192.168.0.0/24(rw,sync,no_subtree_check,all_squash,anonuid=0,anongid=0)' | sudo tee /etc/exports
sudo systemctl restart nfs-kernel-server
```
Reference: https://microk8s.io/docs/how-to-nfs

# Storage using an NFS server

Install the NFS CSI Driver using helm
Add the Helm repo
```helm repo add csi-driver-nfs https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/charts```

Install the helm chart in the kube-system namespace
```helm install csi-driver-nfs csi-driver-nfs/csi-driver-nfs --namespace kube-system --version v4.5.0```

Wait a couple minutes and install the storage class i.e. k apply -f storageclass.yaml