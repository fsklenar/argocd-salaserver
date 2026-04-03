## ArgoCD for k8s-salaserver

ArgoCD configuration with applications deployed by:
- manifests files
- helm charts

See the Architecture diagram [here](https://htmlpreview.github.io/?https://github.com/fsklenar/argocd-salaserver/blob/main/infra-schema.html)

ArgoCD install:
``` 
kubectl apply -f https://github.com/argoproj/argo-cd/blob/master/manifests/install.yaml -n argocd --server-side --force-conflicts
```

### Cilium
https://docs.cilium.io/en/stable/gettingstarted/k8s-install-default/
