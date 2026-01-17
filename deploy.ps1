Write-Host "Starting deployment..." -ForegroundColor Cyan

# Step 0: Check for ingress-nginx namespace
$ingressNamespace = kubectl get ns ingress-nginx --no-headers -o custom-columns=":metadata.name" 2>$null
if (-not $ingressNamespace) {
    Write-Host "NGINX Ingress Controller not found. Installing..." -ForegroundColor Yellow
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.11.3/deploy/static/provider/cloud/deploy.yaml

    Write-Host "Waiting for Ingress controller pods to be ready..."
    kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=180s
} else {
    Write-Host "NGINX Ingress Controller already installed." -ForegroundColor Green
}

# Step 1: Build Docker images
Write-Host "Building backend image..." -ForegroundColor Cyan
docker build -t akterfaruq/finch-backend ./backend

Write-Host "Building frontend image..." -ForegroundColor Cyan
docker build -t akterfaruq/finch-frontend ./frontend

# Step 2: Apply Kubernetes manifests
Write-Host "Applying Kubernetes manifests..." -ForegroundColor Cyan
kubectl apply -f kubernetes/secrets/db-secrets.yaml
kubectl apply -f kubernetes/postgres-deployment.yaml
kubectl apply -f kubernetes/redis-deployment.yaml
kubectl apply -f kubernetes/backend-deployment.yaml
kubectl apply -f kubernetes/frontend-deployment.yaml
kubectl apply -f kubernetes/ingress.yaml

# Step 3: Wait for all pods to be ready
Write-Host "Waiting for all pods to be ready..." -ForegroundColor Cyan
$pods = kubectl get pods --no-headers | ForEach-Object { ($_ -split "\s+")[0] }
foreach ($pod in $pods) {
    Write-Host "Waiting for pod $pod condition..." -ForegroundColor Yellow
    kubectl wait --for=condition=Ready pod/$pod --timeout=180s
}

# Step 4: Show cluster status
Write-Host "`nCluster status:" -ForegroundColor Cyan
kubectl get pods
kubectl get svc
kubectl get ingress

# Step 5: Port-forward frontend to 127.0.0.1:8001 for testing
Write-Host "`nPort-forwarding frontend to 127.0.0.1:8001..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList "kubectl port-forward svc/frontend 8001:80" -NoNewWindow

Write-Host "`nDeployment completed successfully!" -ForegroundColor Green
Write-Host "Access your frontend at http://127.0.0.1:8001"
