## Upgrade to Gutlab 19 - helm chart breaking changes
https://docs.gitlab.com/charts/installation/migration/bundled_chart_migration/
gitlab helm chart values: https://gitlab.com/gitlab-org/charts/gitlab/-/blob/master/values.yaml

## !!!!!IMPORTANT!!!!!
### Garage Installation:
 helm repo add garage-helm https://datahub-local.github.io/garage-helm

 helm install garage garage-helm/garage -n gitlab -f values.yaml

 pod_prefix=garage
 kubectl exec ${pod_prefix}-0 -n gitlab  -- /garage status

 kubectl exec ${pod_prefix}-0 -n gitlab  -- /garage layout assign -z gitlab1 -c 5Gi <node1id>
 kubectl exec ${pod_prefix}-1 -n gitlab  -- /garage layout assign -z gitlab2 -c 5Gi <node2id>
 kubectl exec ${pod_prefix}-2 -n gitlab  -- /garage layout assign -z gitlab3 -c 5Gi <node3id>

 kubectl exec ${pod_prefix}-0 -n gitlab -- /garage layout apply --version 1


 buckets=("git-lfs" "gitlab-agent-plan-content" "gitlab-artifacts" "gitlab-backups" \
          "gitlab-ci-secure-files" "gitlab-dependency-proxy" "gitlab-mr-diffs" \
          "gitlab-packages" "gitlab-pages" "gitlab-terraform-state" "gitlab-uploads" \
          "registry" "runner-cache" "tmp" )
 for bucket in "${buckets[@]}"; do
   kubectl exec -n gitlab ${pod_prefix}-0  -- /garage bucket create "${bucket}";
 done


 local KEY_OUTPUT
 KEY_OUTPUT=$(kubectl exec -n gitlab ${pod_prefix}-0 -- \
     /garage key create gitlab-app-key)

 local GARAGE_ACCESS_KEY GARAGE_SECRET_KEY
 GARAGE_ACCESS_KEY=$(echo "${KEY_OUTPUT}" | grep 'Key ID:' | awk '{print $3}')
 GARAGE_SECRET_KEY=$(echo "${KEY_OUTPUT}" | grep 'Secret key:' | awk '{print $3}')

  Grant permissions to the GitLab key.
 for bucket in "${buckets[@]}"; do
   kubectl exec -n gitlab ${pod_prefix}-0  -- /garage bucket allow --read --write --key gitlab-app-key "${bucket}";
 done



 cat <<EOF | kubectl create secret generic gitlab-object-storage -n gitlab --from-file=config=/dev/stdin
 provider: AWS
 region: garage
 aws_access_key_id: ${GARAGE_ACCESS_KEY}
 aws_secret_access_key: ${GARAGE_SECRET_KEY}
 endpoint: "http://${pod_prefix}.gitlab.svc.cluster.local:3900"
 path_style: true
 EOF


 cat <<EOF | kubectl create secret generic gitlab-object-storage-s3cmd -n gitlab --from-file=config=/dev/stdin
 [default]
 access_key = ${GARAGE_ACCESS_KEY}
 secret_key = ${GARAGE_SECRET_KEY}
 host_base = ${pod_prefix}.gitlab.svc.cluster.local:3900
 host_bucket = ${pod_prefix}.gitlab.svc.cluster.local:3900
 use_https = False
 EOF


 cat <<EOF | kubectl create secret generic gitlab-registry-storage -n gitlab --from-file=config=/dev/stdin
 s3:
   accesskey: ${GARAGE_ACCESS_KEY}
   secretkey: ${GARAGE_SECRET_KEY}
   bucket: registry
   region: garage
   regionendpoint: http://${pod_prefix}.gitlab.svc.cluster.local:3900
   secure: false
   v4auth: true
   pathstyle: true
 EOF
