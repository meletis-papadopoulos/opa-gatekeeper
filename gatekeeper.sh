#!/bin/bash

# Set namespace
kubectl config set-context --current --namespace default

# OPA Gatekeeper script

# Check to see if you're root user
if [[ "${UID}" -ne 0 ]]; then
  echo "You must the script as root." >&2
  exit 1
fi

# Check status
echo $?

# Install Metrics Server (To Do...)
# Check the version of Metrics Server (don't use the latest), and use hacks
# in order to make it properly work!

# Then continue with deploy/sts and apply an HPA

printf "Applying OPA Gatekeeper resources..."
printf "\n"

# Make sure Gatekeeper resources are installed (use pre-built image)
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/v3.16.3/deploy/gatekeeper.yaml

# Check status
echo $?

printf "Applying Constraint Template..."
printf "\n"

# Apply OPA Constrant Template
cat <<EOF | kubectl create -f -
apiVersion: templates.gatekeeper.sh/v1beta1
kind: ConstraintTemplate
metadata:
  name: k8srequirehpa
spec:
  crd:
    spec:
      names:
        kind: K8sRequireHPA
      validation:
        # Schema for parameters field
        openAPIV3Schema:
          properties:
            message:
              type: string
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package k8srequirehpa

        violation[{"msg": message}] {
          input.review.kind.kind == "Deployment" 
          not hpa_exists
          message := "There is no HPA present for higher environment usage, please consider adding one"
        }

        violation[{"msg": message}] {
          input.review.kind.kind == "StatefulSet"
          not hpa_exists
          message := "There is no HPA present for higher environment usage, please consider adding one"
        }

        violation[{"msg": message}] {
          hpa_exists
          min_replicas == 1
          message := "Given the application is set to scale, for higher environments you must set HPA minimum replica to greater than 1"
        }

        hpa_exists {
          hpas := {hpa | hpa := input.review.objects.hpa}
          count(hpas) > 0
        }

        min_replicas := hpa.spec.minReplicas {
          hpa := input.review.objects.hpa[_]
        }
EOF

# Check Status (Success/Fail?)
echo $?

printf "Applying Constraint..."
printf "\n"

# Apply OPA Constraint
cat <<EOF | kubectl create -f -
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sRequireHPA
metadata:
  name: require-hpa-for-deployments-and-statefulsets
spec:
  match:
    kinds:
      - apiGroups: ["apps"]
        kinds: ["Deployment", "StatefulSet"]
  parameters:
    message: "Given the application is set to scale, for higher environments you must set HPA minimum replica to greater than 1"
EOF

# Check Status (Success/Fail?)
echo $?

printf "Applying test resources..."
printf "\n"

# Apply Resources
cat <<EOF | kubectl create -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: php-apache
spec:
  selector:
    matchLabels:
      run: php-apache
  template:
    metadata:
      labels:
        run: php-apache
    spec:
      containers:
      - name: php-apache
        image: registry.k8s.io/hpa-example
        ports:
        - containerPort: 80
        resources:
          limits:
            cpu: 500m
          requests:
            cpu: 200m
EOF

# Check Status (Success/Fail?)
echo $?

printf "\n"
printf "\n"

# Apply Service
cat <<EOF | kubectl create -f -
apiVersion: v1
kind: Service
metadata:
  name: php-apache
  labels:
    run: php-apache
spec:
  ports:
  - port: 80
  selector:
    run: php-apache
EOF

# Check Status (Success/Fail?)
echo $?

printf "Cleaning up...\n"
printf "\n"

# CLEAN UP

# Remove php-apache deployment
kubectl -n default delete deployment php-apache --force --grace-period 0
printf "\n"

# Delete php-apache service
kubectl -n default delete svc php-apache --force --grace-period 0
printf "\n"

# Uninstall Gatekeeper
kubectl delete -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/v3.16.3/deploy/gatekeeper.yaml
printf "\n"

# Check status (Was everything removed successfully?)
echo $?

exit 0

