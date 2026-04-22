@echo off
echo Deploying remaining services with fixed YAML...
kubectl apply -f k8s/09-delivery-service-deployment.yaml -n fooddelivery || echo "09 failed - use fixed"
kubectl apply -f k8s/10-order-service-deployment.yaml -n fooddelivery || echo "10 failed"
kubectl apply -f k8s/11-admin-service-deployment.yaml -n fooddelivery || echo "11 failed"
kubectl apply -f k8s/12-frontend-deployment.yaml -n fooddelivery || echo "12 failed"

echo Rollout status...
kubectl rollout status deployment/user-service restaurant-service delivery-service order-service admin-service frontend api-gateway pgadmin -n fooddelivery --timeout=300s

kubectl get all -n fooddelivery
pause

