# OPA/Gatekeeper Policy
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
> Use **cleanup.sh** script

```bash
#!/usr/bin/env bash

set -e
set -o pipefail

# Check if "kubectl" is installed
if ! command -v kubectl &>/dev/null; then
    echo "kubectl is not installed. Exiting."
    exit 1
else
    echo "kubectl is installed."
fi

# Set project directory
dir="/root/opa-gatekeeper"

# Function to delete YAML files
delete_resource() {
    local yaml_path="${1}"
    if [[ -f "${yaml_path}" ]]; then
        echo "Deleting resource: ${yaml_path}"
        kubectl delete -f "${yaml_path}" --force --grace-period=0
    else
        echo "YAML file not found: ${yaml_path}"
    fi
    printf "\n"
}

# List of YAML files to delete
yaml_files=(
    "${dir}/gatekeeper/gatekeeper.yaml"
    "${dir}/hpa/samples/constraint.yaml"
    "${dir}/hpa/template.yaml"
    "${dir}/metrics-server/metrics-server.yaml"
    "${dir}/hpa/samples/example-allowed-hpa.yaml"
    "${dir}/hpa/samples/nginx-deploy.yaml"
)

# Loop through each YAML and delete
for yaml in "${yaml_files[@]}"; do
    delete_resource "${yaml}"
done

# Success message
echo "All resources deleted successfully!"
```

## Links
HPA walkthrough **[k8s docs](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/)**

OPA policies library **[horizontalpodautoscaler](https://github.com/open-policy-agent/gatekeeper-library/tree/master/library/general/horizontalpodautoscaler)**