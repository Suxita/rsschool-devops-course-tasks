# Ensure minikube is running with sufficient resources
if (-not (minikube status | Select-String "host: Running")) {
    Write-Host "Starting Minikube..." -ForegroundColor Cyan
    minikube start --driver=docker --memory=1850 --cpus=2
    minikube addons enable ingress
    
    # Wait for cluster to stabilize
    Write-Host "Waiting for cluster to initialize..."
    Start-Sleep -Seconds 60
}

# Set Docker environment to use Minikube's Docker daemon
minikube docker-env | Invoke-Expression

# --- Build and Deploy ---

# Build the docker image from the 'app' sub-directory
Write-Host "Building Docker image..." -ForegroundColor Cyan
docker build -t flask-app:latest ./app

# Create the namespace if it doesn't exist
Write-Host "Creating Kubernetes namespace..." -ForegroundColor Cyan
kubectl create namespace flask-app --dry-run=client -o yaml | kubectl apply -f -

# Deploy the application using the helm chart from the 'helm-chart' sub-directory
Write-Host "Deploying application with Helm..." -ForegroundColor Cyan
helm upgrade --install flask-app ./helm-chart -n flask-app

# Wait for deployment to be ready
Write-Host "Waiting for deployment to complete..." -ForegroundColor Yellow
Start-Sleep -Seconds 20

# Verify deployment rollout status using the correct name (ReleaseName-ChartName)
kubectl rollout status deployment/flask-app-flask-app -n flask-app --timeout=120s

# Get access information
$ip = minikube ip
Write-Host "`n=== Access Information ===" -ForegroundColor Green
Write-Host "1. Add the following line to your hosts file: $ip flask-app.local"
Write-Host "   (You can use the setup-host.ps1 script as an Administrator)"
Write-Host "2. Access the application at: http://flask-app.local`n"
Write-Host "3. Alternatively, use port-forwarding: kubectl port-forward svc/flask-app-flask-app 8080:80 -n flask-app"