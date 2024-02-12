ignore out of sync errors:
add the below to the argocd configmap:
```data:
  resource.customizations.ignoreEmpty: "true"
  resource.customizations.ignoreDifferences.all: |
    jsonPointers:
    - /metadata/labels/app.kubernetes.io~1instance
    - /metadata/labels```