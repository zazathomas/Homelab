# Storage using an NFS server

Install the NFS CSI Driver using helm
Add the Helm repo
```helm repo add csi-driver-nfs https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/charts```

Install the helm chart in the kube-system namespace
```helm install csi-driver-nfs csi-driver-nfs/csi-driver-nfs --namespace kube-system --version v4.5.0```

Wait a couple minutes and install the storage class


Reference: https://microk8s.io/docs/how-to-nfs