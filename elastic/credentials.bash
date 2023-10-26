#!/bin/bash
bold=$(tput bold)
normal=$(tput sgr0)

echo "${bold}ELASTIC USERNAME:${normal} $(kubectl get secret elasticsearch-master-credentials -o jsonpath='{.data}' -n elastic | jq -r .username | base64 --decode)"
echo "${bold}ELASTIC PASSWORD:${normal} $(kubectl get secret elasticsearch-master-credentials -o jsonpath='{.data}' -n elastic | jq -r .password | base64 --decode)"
echo "${bold}Please expose elasticsearch and kibana to view dashboards locally${normal}"
echo "${bold}------------------------------------------------------${normal}"