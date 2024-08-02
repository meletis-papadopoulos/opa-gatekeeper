#!/bin/bash

# Change to scripts path
PATH="/root/OPA-GateKeeper/scripts"

cd ${PATH}

# Remove Deployment/Service/HPA
kubectl delete -f php-apache.yaml --force --grace-period 0

printf "\n"

# Uninstall Gatekeeper Resources
kubectl delete -f gatekeeper.yaml --force -grace-period 0

printf "\n"

# Delete Constraint & Constraint Template
kubectl delete -f hpa-replicas-constraint.yaml --force --grace-period 0
kubectl delete -f hpa-replicas.yaml --force --grace-period 0

printf "\n"

# Remove Metrics Server
kubectl delete -f metrics-server.yaml --force --grace-period 0

# Check status
echo $?
