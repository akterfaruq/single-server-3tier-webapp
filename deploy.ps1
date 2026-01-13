Write-Host "Starting deployment..."

docker build -t finch-backend ./backend
docker build -t finch-frontend ./frontend

kubectl apply -f kubernetes/secrets/db-secrets.yaml
kubectl apply -f kubernetes/postgres-deployment.yaml
kubectl apply -f kubernetes/redis-deployment.yaml
kubectl apply -f kubernetes/backend-deployment.yaml
kubectl apply -f kubernetes/frontend-deployment.yaml
kubectl apply -f kubernetes/ingress.yaml

kubectl get pods
kubectl get svc
kubectl get ingress

Write-Host "Deployment completed successfully!"
