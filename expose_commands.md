## EXPOSE GRAFANA (local port 3000)
```kubectl port-forward -n monitoring service/kube-prometheus-stack-grafana 3000:80```

## EXPOSE PROMETHEUS
```kubectl port-forward -n monitoring service/kube-prometheus-stack-prometheus 9090:9090```