#!/bin/bash

# OPA Gatekeeper Policy

# Switch to default namespace
kubectl config set-context --current --namespace default

# Check to see if you're root user
if [[ "${UID}" -ne 0 ]]; then
  echo "You must the script as root." >&2
  exit 1
fi

# Check status
echo $?

printf "\n"

# Override default vim settings
VIM_PATH="/etc/vim/vimrc"

echo "set ai" >> ${VIM_PATH}
echo "set nu" >> ${VIM_PATH}
echo "set et" >> ${VIM_PATH}
echo "set sw=2" >> ${VIM_PATH}
echo "set ts=2" >> ${VIM_PATH}

cat ${VIM_PATH}

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

# Check status
echo $?

printf "\n"
printf "Applying OPA Gatekeeper resources..."

# Make sure Gatekeeper resources are installed (use pre-built image)
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/v3.16.3/deploy/gatekeeper.yaml

# Check status
echo $?

printf "\n"

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

printf "\n"

# Check Status
echo $?

printf "\n"
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

# Check Status
echo $?

printf "\n"
printf "Applying test resources..."
printf "\n"

# Apply Deployment
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

printf "\n"

# Check Status
echo $?

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

printf "\n"

# Check Status
echo $?

printf "\n"

# Create the HorizontalPodAutoscaler
cat <<EOF | kubectl -f -
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: php-apache
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: php-apache
  minReplicas: 1
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
EOF

# Check status
echo $?

printf "\n"

# CLEAN UP

printf "Cleaning up...\n"
printf "\n"

# Remove Metrics Server
cd ${METRICS_SERVER}
kubectl delete -f components.yaml --force --grace-period 0

printf "\n"

# Remove HPA
kubectl delete hpa php-apache --force --grace-period 0

printf "\n"

# Uninstall Gatekeeper
kubectl delete -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/v3.16.3/deploy/gatekeeper.yaml

printf "\n"

# Remove php-apache deployment
kubectl -n default delete deployment php-apache --force --grace-period 0
printf "\n"

# Delete php-apache service
kubectl -n default delete svc php-apache --force --grace-period 0

printf "\n"

# Check status
echo $?

printf "\n"

exit 0
