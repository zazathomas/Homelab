# Gateway API Setup for Cilium with OCI Load Balancer Integration
This guide outlines the steps to install the necessary Custom Resource Definitions (CRDs) for the Gateway API, configure Cilium, and set up a Gateway object with OCI Load Balancer integration for Kubernetes clusters.

1. Install Gateway API CRDs
To enable Gateway API functionality in your Kubernetes cluster, apply the following CRDs from the kubernetes-sigs repository:
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.1.0/config/crd/standard/gateway.networking.k8s.io_gatewayclasses.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.1.0/config/crd/standard/gateway.networking.k8s.io_gateways.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.1.0/config/crd/standard/gateway.networking.k8s.io_httproutes.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.1.0/config/crd/standard/gateway.networking.k8s.io_referencegrants.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.1.0/config/crd/standard/gateway.networking.k8s.io_grpcroutes.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.1.0/config/crd/experimental/gateway.networking.k8s.io_tlsroutes.yaml
```
2. Enable Gateway API & Envoy in Cilium
To enable the Gateway API functionality within Cilium, ensure that the gatewayAPI.enabled & envoy.enabled flag is set to true in your Cilium values.yaml configuration file.
```
# Enable Gateway API
gatewayAPI:
  enabled: true
# Enable envoy
envoy:
  enabled: true
  ```
Then, upgrade Cilium to apply the changes:
`cilium upgrade -f values-cloud.yaml`

3. Create a Cilium Gateway Object
Define and create the Cilium Gateway object, specifying the necessary TLS secret for HTTPS termination, which is managed by cert-manager. Apply the gateway configuration using the following command:
`kubectl apply -f gateway.yaml`

4. Configure OCI Load Balancer Annotations
To ensure proper load balancer configuration for Oracle Cloud Infrastructure (OCI), modify the service annotations. This is crucial, especially for setting the appropriate load balancer size on the OCI Free Tier. Add the following annotations to the Gateway service:

```
annotations:
  service.beta.kubernetes.io/oci-load-balancer-shape-flex-max: "10"
  service.beta.kubernetes.io/oci-load-balancer-shape-flex-min: "10"
  service.beta.kubernetes.io/oci-load-balancer-shape: "flexible"
  oci.oraclecloud.com/load-balancer-type: "lb"
```

5. Set Up HTTP to HTTPS Redirection
Create an HTTPRoute object that handles HTTP to HTTPS redirection to ensure that all HTTP traffic is securely routed to HTTPS.

6. Define HTTPRoute and TLSRoute for Services
For each service, create individual HTTPRoute and TLSRoute resources to handle traffic according to your specific requirements.

7. Additional Resources
The following resources were instrumental in setting up this configuration:

[Gateway API Setup with Cilium and Load Balancing](https://kubito.dev/posts/gateway-api-setup-cilium-load-balancing/)
[Kubernetes External Services Setup](https://blog.stonegarden.dev/articles/2024/04/k8s-external-services/)
[Cilium Gateway API Configuration](https://blog.stonegarden.dev/articles/2023/12/cilium-gateway-api/)

This guide should provide a streamlined approach to integrating the Gateway API with Cilium and OCI Load Balancer for secure and scalable Kubernetes ingress management.