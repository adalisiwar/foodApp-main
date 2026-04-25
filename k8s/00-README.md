# Kubernetes Deployment for Food Delivery App

## Quick Start (Docker Desktop K8s)

1. Install kompose:
   ```powershell
   (New-Object Net.WebClient).DownloadFile('https://github.com/kubernetes/kompose/releases/download/v1.34.0/kompose-windows-amd64.exe', 'kompose.exe')
   ```
   Add to PATH:
   `$env:Path += ';c:/Users/adali/Downloads/foodApp-main/foodApp-main'`

2. Generate manifests:
   `kompose convert --with-kompose-annotation=false -f docker-compose.yml -o k8s/`

3. Review/edit generated files (postgres to StatefulSet, add secrets/resources).

4. Apply:
   `kubectl create ns fooddelivery`
   `kubectl apply -f k8s/`

5. Port forwards:
   `kubectl port-forward -n fooddelivery svc/frontend 18080:80`
   `kubectl port-forward -n fooddelivery deployment/eureka-server 8761:8761`
   `kubectl port-forward -n fooddelivery deployment/api-gateway 9000:9000`

Frontend: `http://localhost:18080`
Admin login: `http://localhost:18080/admin/login`
Eureka: `http://localhost:8761`

## Manual Manifests (production-ready)
- `01-namespace.yaml`
- `02-configmap-secrets.yaml`
- `03-postgres-statefulset.yaml`
- `...`

`kubectl get all -n fooddelivery`
