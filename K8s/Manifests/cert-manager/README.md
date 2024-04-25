# Cert-manager

To establish secure communication within the Homelab, let's kick things off by applying the Certificate Manager custom resource definitions (CRDs) to the target cluster. You can run the following command or not:

`kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.1/cert-manager.crds.yaml`

Next up, let's create a dedicated namespace for the Cert-Manager to operate within. This helps keep things nice and organized a:

`kubectl create namespace cert-manager`

With the groundwork laid, it's time to install  Cert-Manager using Helm. This process streamlines the deployment and configuration process:

`helm install cert-manager jetstack/cert-manager --namespace cert-manager --values=values.yaml --version v1.14.1`


Given that the certificate is applied as a secret to the default namespace, we need a reflector to propagate it to the required namespaces. Enter the Reflector Operator, a handy tool designed for this very purpose. You can install it effortlessly using the following commands:

`helm repo add emberstack https://emberstack.github.io/helm-charts`
`helm repo update`
`helm upgrade --install reflector emberstack/reflector --namespace kube-system`

Once the Reflector Operator is up and running, it's time to tweak the certificate manifest file. By adding specific annotations to the spec section, we can ensure that the secret is reflected and available for use in designated namespaces. Here's an example snippet to get you started:

secretTemplate:
    annotations:
      reflector.v1.k8s.emberstack.com/reflection-allowed: "true"
      reflector.v1.k8s.emberstack.com/reflection-allowed-namespaces: "dev,staging,prod" # Customize as needed
      reflector.v1.k8s.emberstack.com/reflection-auto-enabled: "true" 
      reflector.v1.k8s.emberstack.com/reflection-auto-namespaces: "dev,staging,prod" # Customize as needed


With these steps completed, your secret will now be readily available for use by IngressRoutes in the specified namespaces, ensuring secure communication throughout the cluster.