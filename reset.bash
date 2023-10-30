#!/bin/bash
bold=$(tput bold)
normal=$(tput sgr0)

echo "${bold}Stopping minikube cluster${normal}"
minikube stop
echo ${bold}"Deleting minikube profile${normal}"
minikube delete --profile minikube