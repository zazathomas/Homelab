
# **Cert-Manager Deployment**  

This guide provides a structured approach to deploying **Cert-Manager** within a **Kubernetes Homelab environment**, ensuring **secure communication** across the cluster.  

---

## **1. Deploying Cert-Manager**  

### **Step 1: Install Cert-Manager Using Helm**  

Leverage Helm to simplify the deployment and configuration:  

```bash
helm repo add jetstack https://charts.jetstack.io
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --values=values.yaml \
  --create--namespace \
  --set installCRDs=true
```

---

## **2. Configuring Secret Propagation with Reflector Operator**  

By default, **certificates** issued by Cert-Manager are stored as **secrets** in the namespace where they are created. To enable **automatic propagation** of these secrets across multiple namespaces, install the **Reflector Operator**.

### **Step 1: Install Reflector Operator**  

Add the **EmberStack Helm repository** and deploy the **Reflector Operator** in the `kube-system` namespace:  

```bash
helm repo add emberstack https://emberstack.github.io/helm-charts
helm repo update
helm upgrade --install reflector emberstack/reflector --namespace kube-system
```

### **Step 2: Configure the Certificate Manifest for Reflection**  

Modify the **certificate manifest** by adding the following **annotations** under `secretTemplate`. This ensures the certificate is automatically replicated across the required namespaces:  

```yaml
secretTemplate:
  annotations:
    reflector.v1.k8s.emberstack.com/reflection-allowed: "true"
    reflector.v1.k8s.emberstack.com/reflection-allowed-namespaces: "dev,staging,prod" # Customize as needed
    reflector.v1.k8s.emberstack.com/reflection-auto-enabled: "true"
    reflector.v1.k8s.emberstack.com/reflection-auto-namespaces: "dev,staging,prod" # Customize as needed
```

---