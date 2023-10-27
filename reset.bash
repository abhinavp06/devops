#!/bin/bash
bold=$(tput bold)
normal=$(tput sgr0)

echo "${bold}Deleting 'personal' namespace${normal}"
kubectl delete namespace personal
echo "${bold}Deleting 'monitoring' namespace${normal}"
kubectl delete namespace monitoring
echo "${bold}Deleting 'elastic' namespace${normal}"
kubectl delete namespace elastic
echo "${bold}Stopping minikube cluster${normal}"
minikube stop
echo ${bold}"Deleting minikube profile${normal}"
minikube delete --profile minikube