#!/bin/bash

# OPA Gatekeeper Policy
# Block all Deployments/StatefulSets if HPA doesn't exist!

# Check to see if you're root user
if [[ "${UID}" -ne 0 ]]; then
  echo "You must the script as root." >&2
  exit 1
fi

# Check status
echo $?

printf "\n"

# Install Metrics Server (v0.6.3)
printf "Applying Metrics Server resources..."
printf "\n"

# Check status
echo $?

printf "\n"

# Install Gatekeeper resources
# Use the pre-built image
printf "Applying OPA Gatekeeper resources..."
printf "\n"

# Check status
echo $?

printf "\n"

# Apply OPA Constrant Template
printf "Applying Constraint Template..."
printf "\n"

# Apply OPA Constraint
printf "Applying Constraint..."
printf "\n"

# Apply test resources (i.e. Deployment/Service/HPA)
printf "Applying test resources..."
printf "\n"

# Check status
echo $?

printf "\n"

# Clean Up!

printf "CLEANING UP...\n"
printf "\n"

# Remove Deployment/Service/HPA
kubectl delete -f php-apache.yaml --force --grace-period 0

# Check status
echo $?

printf "\n"

# Uninstall Gatekeeper Resources
kubectl delete -f gatekeeper.yaml --force -grace-period 0

printf "\n"

# Check status
echo $?

# Delete Constraint & Constraint Template
kubectl delete -f hpa-replicas-constraint.yaml --force --grace-period 0
kubectl delete -f hpa-replicas.yaml --force --grace-period 0

# Check status
echo $?

printf "\n"

# Remove Metrics Server
kubectl delete -f metrics-server.yaml --force --grace-period 0

# Check status
echo $?

printf "\n"

# Done
exit 0
