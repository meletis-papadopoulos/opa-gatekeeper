#!/bin/bash
  
# Change to project directory
PATH="/root/OPA-GateKeeper"

# Path to kubectl command
k="/usr/bin/kubectl"

# Uninstall Gatekeeper Resources
cd ${PATH}/gatekeeper

$k delete -f gatekeeper.yaml --force --grace-period 0

printf "\n"

# Delete Constraint
cd ${PATH}/hpa/samples/horizontalpodautoscaler/

$k delete -f constraint.yaml --force --grace-period 0

printf "\n"

# Delete Constraint Template
cd ${PATH}/hpa/

$k delete -f template.yaml --force --grace-period 0

printf "\n"

# Remove Metrics Server
cd ${PATH}/metrics-server/

$k delete -f metrics-server.yaml --force --grace-period 0

printf "\n"

# Check status
echo $?