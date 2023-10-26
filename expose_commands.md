## EXPOSE GRAFANA (local port 3000)
```kubectl port-forward -n monitoring service/kube-prometheus-stack-grafana 3000:80```
### Alternate: 
```minikube service kube-prometheus-stack-grafana -n monitoring --url```

## EXPOSE PROMETHEUS (local port 9090)
```kubectl port-forward -n monitoring service/kube-prometheus-stack-prometheus 9090:9090```
### Alternate: 
```minikube service kube-prometheus-stack-prometheus -n monitoring --url```

## EXPOSE ELASTICSEARCH (local port 9200)
```kubectl port-forward svc/elasticsearch-master 9200 -n elastic```
### Alternate: 
```minikube service elasticsearch-master -n elastic --url```

## EXPOSE KIBANA (local port 5601)
```kubectl port-forward deployment/kibana-kibana 5601 -n elastic```
### Alternate: 
```minikube service kibana-kibana -n elastic --url```