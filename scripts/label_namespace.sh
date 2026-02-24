# Define the label to add
LABEL_KEY="test"
LABEL_VALUE="val"
FULL_LABEL="${LABEL_KEY}=${LABEL_VALUE}"

echo "Adding label '${FULL_LABEL}' to all Kubernetes namespaces..."

# Get all namespace names and loop through them
kubectl get namespaces -o jsonpath='{.items[*].metadata.name}' | tr ' ' '\n' | while IFS= read -r namespace; do
  echo "Processing namespace: ${namespace}"
  # Add the label to the current namespace
  # --overwrite allows updating the label if it already exists with a different value
  kubectl label namespace "${namespace}" "${FULL_LABEL}" --overwrite
  sleep 2
  kubectl label namespace "${namespace}" "${LABEL_KEY}-"
  if [ $? -eq 0 ]; then
    echo "Successfully added label to namespace: ${namespace}"
  else
    echo "Failed to add label to namespace: ${namespace}"
  fi
done

echo "Script finished."
