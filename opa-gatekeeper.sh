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
HOME="/root/"
METRICS_SERVER="${HOME}/metrics-server"
mkdir ${METRICS_SERVER}
cd ${METRICS_SERVER}

# Get the metrics server manifest file
URL="https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.6.3/components.yaml"
wget ${URL} metrics-server.yaml

# Check status
echo $?

printf "\n"

# Apply the following fixes to the metrics server deployment manifest:
# Use:  a. "--kubelet-insecure-tls=true"
#       b. "hostNetwork: true"

# Finally, apply the modified manifest
kubectl create -f components.yaml

# Check status
echo $?

printf "\n"

# Install Gatekeeper resources
# Use the pre-built image
printf "Applying OPA Gatekeeper resources..."
printf "\n"

kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/v3.16.3/deploy/gatekeeper.yaml

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
kubectl delete -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/v3.16.3/deploy/gatekeeper.yaml --force -grace-period 0

printf "\n"

# Check status
echo $?

# Delete Constraint & Constraint Template
kubectl delete -f Constraint.yaml --force --grace-period 0
kubectl delete -f ConstraintTemplate.yaml --force --grace-period 0

# Check status
echo $?

printf "\n"

# Remove Metrics Server
cd ${METRICS_SERVER}
kubectl delete -f components.yaml --force --grace-period 0

# Check status
echo $?

printf "\n"

# Done
exit 0
