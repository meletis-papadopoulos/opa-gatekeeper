#!/bin/bash

# Change to scripts path
readonly PATH="/root/OPA-GateKeeper/"

# Uninstall Gatekeeper Resources
cd ${PATH}/gatekeeper

kubectl delete -f gatekeeper.yaml --force -grace-period 0

printf "\n"

# Delete Constraint
cd ${PATH}/horizontalpodautoscaler/samples

kubectl delete -f constraint.yaml --force --grace-period 0

printf "\n"

# Delete Constraint Template
cd ${PATH}/horizontalpodautoscaler/

kubectl delete -f template.yaml --force --grace-period 0

printf "\n"

# Remove Metrics Server
cd ${PATH}/metrics-server

kubectl delete -f metrics-server.yaml --force --grace-period 0

# Check status
echo $?