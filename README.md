# OPA/GateKeeper Policy
> Block all Deployments/StatefulSets if a HPA doesn't exist!

## Description
> The project consists of 5 folders:
- **gatekeeper** -> YAML definition for OPA/Gatekeeper
- **hpa** -> Template, Constraint and test resources
- **metrics-server** -> YAML definition for Metrics Server
- **script** -> Clean up applied resources
- **ticket** -> OPA/Gatekeeper policy requirements

## How to run
> You need to have **root** privileges on the cluster!

- Install Metrics Server (i.e. v0.6.3)
- Install Gatekeeper resources (use a pre-built image)
- Apply OPA Constrant Template
- Apply OPA Constraint
- Create/Test sample resources (i.e. Deployment)
- Clean Up!

## Remove applied resources
> Use **clean-up.sh** script

```bash
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
```

## Links
HPA walkthrough **[k8s docs](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/)**

OPA policies library **[horizontalpodautoscaler](https://github.com/open-policy-agent/gatekeeper-library/tree/master/library/general/horizontalpodautoscaler)**