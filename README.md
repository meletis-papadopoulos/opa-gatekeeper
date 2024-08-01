# OPA-GateKeeper Policy

#### Block all Deployments/StatefulSets if HPA doesn't exist!

> Make sure you have root privileges on the cluster

- Install Metrics Server (i.e. v0.6.3)
- Install Gatekeeper resources (use a pre-built image)
- Apply OPA Constrant Template
- Apply OPA Constraint
- Create test resources (i.e. Deployment/Service/HPA)
- Clean Up!

> To remove all applied resources, use the script (**cleanup.sh**)

```bash
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
