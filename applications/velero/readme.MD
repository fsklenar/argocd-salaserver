velero backup get
velero backup create testk8s-salaserver
velero schedule create testk8s-salaserver-schedule --schedule="0 3 * * *"
velero backup describe testk8s-salaserver
velero backup logs testk8s-salaserver
velero backup delete testk8s-salaserver
