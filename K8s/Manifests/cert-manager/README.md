# Cert-manager

apply the cert manager custom resource definitions to the given cluster
```kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.1/cert-manager.crds.yaml```

Create namespace for cert-manager
```kubectl create namespace cert-manager```

Install cert manager using helm
```helm install cert-manager jetstack/cert-manager --namespace cert-manager --values=values.yaml --version v1.14.1```


Since the certificate is applied as a secret to the default namespace, a reflector is required to propagate the secret to the required namespace
A reflector operator is used to acheive this: https://github.com/emberstack/kubernetes-reflector/blob/main/README.md

Install the operator using:
```
helm repo add emberstack https://emberstack.github.io/helm-charts
helm repo update
helm upgrade --install reflector emberstack/reflector --namespace cert-manager
```

Afterwards add the below to the spec section of the certificate manifest file:
```
secretTemplate:
    annotations:
      reflector.v1.k8s.emberstack.com/reflection-allowed: "true"
      reflector.v1.k8s.emberstack.com/reflection-allowed-namespaces: "dev,staging,prod" # Replace this with the namespaces required
      reflector.v1.k8s.emberstack.com/reflection-auto-enabled: "true" 
      reflector.v1.k8s.emberstack.com/reflection-auto-namespaces: "dev,staging,prod" # Replace this with the namespaces required
```

Now the secret will be available for ingressroutes in the specified namespaces above to use.