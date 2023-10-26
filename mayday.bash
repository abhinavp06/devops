#!/bin/bash
echo "Deleting 'personal' namespace"
kubectl delete namespace personal
echo "Deleting 'monitoring' namespace"
kubectl delete namespace monitoring