ignore out of sync errors:
add the below to the argocd configmap:
```data:
  resource.customizations.ignoreEmpty: "true"
  resource.customizations.ignoreDifferences.all: |
    jsonPointers:
    - /metadata/labels/app.kubernetes.io~1instance
    - /metadata/labels```

kubectl create namespace argocd
kubens argocd
helm repo add argo https://argoproj.github.io/argo-helm
helm search repo argo
helm show values argo/argo-cd > values.yaml
helm install --values values.yaml argocd argo/argo-cd 
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode ; echo