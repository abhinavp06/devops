#!/bin/bash
echo "Adding helm charts for kube-prometheus-stack"
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
echo "Starting minikube"
minikube start
echo "Adding minikube metrics-server addon"
minikube addons enable metrics-server
echo "Creating 'personal' and 'monitoring' namespace"
kubectl create namespace personal
kubectl create namespace monitoring
echo "Build docker image for service-a and load it in minikube"
cd service-a
npm i
docker build -t service-a .
minikube image load service-a
cd ..
echo "Build docker image for service-b and load it in minikube"
cd service-b
npm i
docker build -t service-b .
minikube image load service-b
cd ..
echo "Creating dryrun file for 'service-a'"
helm template dryrun ./service-a/deployment/helm-chart/ -f ./service-a/deployment/helm-chart/values.yaml > dryrun-a.yaml
echo "Creating dryrun file for 'service-b'"
helm template dryrun ./service-b/deployment/helm-chart/ -f ./service-b/deployment/helm-chart/values.yaml > dryrun-b.yaml
echo "Add service-a and service-b to the cluster"
kubectl apply -f dryrun-a.yaml -n personal
kubectl apply -f dryrun-b.yaml -n personal

