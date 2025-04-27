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