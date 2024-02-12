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
install ingress
