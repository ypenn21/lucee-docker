
# pipeline

```sh
export namespace=lucee-pipeline
export appnamespace=lucee-app 
oc new-project $appnamespace
helm install lucee-pipeline helm/pipeline --set appNamespace=${appnamespace} -n ${namespace}  --create-namespace
helm upgrade -i lucee-pipeline helm/pipeline --set appNamespace=${appnamespace} -n ${namespace} --create-namespace
```

```sh
tkn pipeline start build-and-deploy \
     -w name=shared-workspace,volumeClaimTemplateFile=https://raw.githubusercontent.com/openshift/pipelines-tutorial/master/01_pipeline/03_persistent_volume_claim.yaml \
     -p deployment-name=lucee-app \
     -p git-url=https://github.com/ypenn21/lucee-docker \
     -p IMAGE=image-registry.openshift-image-registry.svc:5000/${namespace}/lucee-app \
     --showlog \
     --namespace=${namespace} \
     --use-param-defaults
```
