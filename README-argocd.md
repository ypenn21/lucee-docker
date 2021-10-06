# ArgoCD

See <https://docs.openshift.com/container-platform/4.7/cicd/gitops/configuring-sso-for-argo-cd-on-openshift.html>

```sh
export argocd_namespace=example-argocd
export argocd_tenant_namespace=example-argocd-tenant

helm upgrade -i argocd helm/argocd \
  --set subdomain=$(oc get configmap config -n openshift-apiserver -o jsonpath={.data.config\\.yaml} | jq -r .routingConfig.subdomain) \
  -n ${argocd_namespace} --create-namespace

```

Manually add the tenant namespace in the secret *example-default-cluster-config* 

```sh
oc patch secret example-default-cluster-config -n ${argocd_namespace} -p "{\"stringData\":{\"namespaces\":\"${argocd_namespace},${argocd_tenant_namespace}\"}}"
```

Create role and rolebindings in tenant namespace to allow ServiceAccount in argocd namespace to create objects.

```sh
helm upgrade -i argocd-tenant helm/argocd-tenant -n ${argocd_tenant_namespace} --create-namespace
```

Testing RBAC...

Within keycloak, the clients and scopes are already configured to work with Openshift. Simply create a Group called ArgoCDAdmins and assign a User (that has already logged into Openshift) to it. Only this user will have admin access, all other users won't be able to see anything.
