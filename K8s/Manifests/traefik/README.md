## Traefik V3 Install for Kubernetes

### Create namespace for all trafik resources
```kubectl create namespace traefik```

### Delete all pre-existing traefik resources:
i.e. k `delete clusterrole traefik-traefik` && `k delete clusterrolebinding traefik-traefik` && `k delete ingressclass traefik`

### Install Traefik Resource Definitions:
`kubectl apply -f kubernetes-crd-definition-v1.yml`

### Install RBAC for Traefik:
`kubectl apply -f kubernetes-crd-rbac.yml`

### helm install
`helm install --namespace=traefik --create-namespace traefik traefik/traefik --values=values.yaml --version=29.0.1`

### Install traefik dashboard auth middleware
 `k apply -f middleware.yaml`

### Install dashboard secret
`k apply -f dashboard-secret.yaml`

### Install default headers
`k apply -f dashboard-secret.yaml`

### Install dashboard ingress
`k apply -f ingress.yaml`

---


Create namespace for all trafik resources
```kubectl create namespace traefik```

Install traefik using helm:
```helm install --namespace=traefik traefik traefik/traefik --values=values.yaml```

Apply default header to be used by the dashboard:
```kubectl apply -f default-headers.yaml```

Create dashboard secret
```sudo apt-get update
sudo apt-get install apache2-utils
htpasswd -nb username password | openssl base64```

install middleware for traefik dashboard
---