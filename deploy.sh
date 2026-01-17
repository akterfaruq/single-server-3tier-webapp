#!/bin/bash
set -e

echo "Starting deployment..."

# Step 0: Check ingress-nginx
if ! kubectl get ns ingress-nginx >/dev/null 2>&1; then
  echo "NGINX Ingress Controller not found. Installing..."
  kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.15.0/deploy/static/provider/cloud/deploy.yaml
  echo "Waiting for Ingress controller pods..."
  kubectl wait --namespace ingress-nginx \
    --for=condition=ready pod \
    --selector=app.kubernetes.io/component=controller \
    --timeout=180s
else
  echo "NGINX Ingress Controller already installed."
fi

# Step 1: Build Docker images
echo "Building backend image..."
docker build -t akterfaruq/finch-backend ./backend

echo "Building frontend image..."
docker build -t akterfaruq/finch-frontend ./frontend

# Step 2: Apply Kubernetes manifests
echo "Applying Kubernetes manifests..."
kubectl apply -f kubernetes/secrets/db-secrets.yaml
kubectl apply -f kubernetes/postgres-deployment.yaml
kubectl apply -f kubernetes/redis-deployment.yaml
kubectl apply -f kubernetes/backend-deployment.yaml
kubectl apply -f kubernetes/frontend-deployment.yaml
kubectl apply -f kubernetes/ingress.yaml

# Step 3: Wait for pods
echo "Waiting for all pods..."
for pod in $(kubectl get pods --no-headers | awk '{print $1}'); do
  kubectl wait --for=condition=Ready pod/$pod --timeout=180s
done

# Step 4: Status
echo "Cluster status:"
kubectl get pods
kubectl get svc
kubectl get ingress

# Step 5: Port-forward
echo "Port-forwarding frontend on 8001..."
kubectl port-forward svc/frontend 8001:80 &
