#!/bin/bash
bold=$(tput bold)
normal=$(tput sgr0)

echo "${bold}Adding helm charts for kube-prometheus-stack and elk-stack${normal}"
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add elastic https://helm.elastic.co 
echo "${bold}------------------------------------------------------${normal}"

echo "${bold}Starting minikube${normal}"
minikube start
echo "${bold}------------------------------------------------------${normal}"
echo "${bold}Adding minikube metrics-server addon${normal}"
minikube addons enable metrics-server
echo "${bold}------------------------------------------------------${normal}"
echo "${bold}Creating additional namespaces${normal}"
kubectl create namespace personal
kubectl create namespace monitoring
kubectl create namespace elastic
echo "${bold}------------------------------------------------------${normal}"

echo "${bold}Building docker image for service-a${normal}"
cd service-a
npm i
docker build -t service-a .
cd ..
echo "${bold}------------------------------------------------------${normal}"
echo "${bold}Building docker image for service-b${normal}"
cd service-b
npm i
docker build -t service-b .
cd ..
echo "${bold}------------------------------------------------------${normal}"
echo "${bold}Loading docker images for service-a and service-b in minikube${normal}"
minikube image load service-a
minikube image load service-b
echo "${bold}------------------------------------------------------${normal}"

echo "${bold}Creating dryrun file for 'service-a'${normal}"
helm template dryrun ./service-a/deployment/helm-chart/ -f ./service-a/deployment/helm-chart/values.yaml > dryrun-a.yaml
echo "${bold}------------------------------------------------------${normal}"
echo "${bold}Creating dryrun file for 'service-b'${normal}"
helm template dryrun ./service-b/deployment/helm-chart/ -f ./service-b/deployment/helm-chart/values.yaml > dryrun-b.yaml
echo "${bold}------------------------------------------------------${normal}"
echo "${bold}Adding service-a and service-b to the cluster${normal}"
kubectl apply -f dryrun-a.yaml -n personal
kubectl apply -f dryrun-b.yaml -n personal
echo "${bold}------------------------------------------------------${normal}"

echo "${bold}Adding prometheus stack to the cluster${normal}"
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack -n monitoring
echo "${bold}------------------------------------------------------${normal}"

echo  "${bold}Adding elasticsearch and kibana to the cluster${normal}"
cd elastic
helm install elasticsearch elastic/elasticsearch -f ./values.yaml -n elastic
helm install kibana elastic/kibana -n elastic
echo "${bold}ELASTIC USERNAME:${normal} $(kubectl get secret elasticsearch-master-credentials -o jsonpath='{.data}' -n elastic | jq -r .username | base64 --decode)"
echo "${bold}ELASTIC PASSWORD:${normal} $(kubectl get secret elasticsearch-master-credentials -o jsonpath='{.data}' -n elastic | jq -r .password | base64 --decode)"
echo "${bold}Please expose kibana to view dashboards locally${normal}"
cd ..
echo "${bold}------------------------------------------------------${normal}"