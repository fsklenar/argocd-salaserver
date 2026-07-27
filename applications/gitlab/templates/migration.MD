## Migration from bundled PostgreSQL:
```
export OLD_PG_POD=$(kubectl get pods -n gitlab -l app.kubernetes.io/name=postgresql -o jsonpath="{.items[0].metadata.name}")
export NEW_CNPG_POD=gitlab-rails-db-1
export OLD_PG_PASSWORD=$(kubectl get secret gitlab-postgresql-password -n gitlab -o jsonpath="{.data.postgresql-postgres-password}" | base64 --decode)
export NEW_CNPG_PASSWORD=$(kubectl get secret gitlab-rails-db-app -n gitlab -o jsonpath="{.data.password}" | base64 --decode)
kubectl exec -i -n gitlab $OLD_PG_POD -- env PGPASSWORD="$OLD_PG_PASSWORD" pg_dump -U postgres -Fc -b -v gitlabhq_production | \
kubectl exec -i -n gitlab $NEW_CNPG_POD -- env PGPASSWORD="$NEW_CNPG_PASSWORD" pg_restore -U gitlab -d gitlabhq_production -h gitlab-rails-db-rw.gitlab --clean --if-exists -v
```
