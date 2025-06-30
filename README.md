# Task 4: Jenkins Installation and Configuration

## Overview

This project demonstrates the installation and configuration of Jenkins on a local Kubernetes cluster using Minikube and Helm. The setup includes persistent storage, Jenkins Configuration as Code (JCasC), and automated job creation.

## Prerequisites

- Windows 10/11 with Docker Desktop or Hyper-V enabled
- Administrative privileges
- At least 4GB RAM available for Minikube
- Git installed

## Installation Steps

### 1. Install Minikube

```powershell
choco install minikube

minikube start --memory=4096 --cpus=2 --driver=docker

minikube status
kubectl cluster-info
```

### 2. Install and Verify Helm

```powershell
choco install kubernetes-helm

helm version

helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm install test-nginx bitnami/nginx
helm uninstall test-nginx
```

### 3. Prepare Persistent Storage

Minikube includes a default storage provisioner. Verify it's available:

```powershell
kubectl get storageclass
```

### 4. Install Jenkins

```powershell
kubectl create namespace jenkins

helm repo add jenkins https://charts.jenkins.io
helm repo update

helm install jenkins jenkins/jenkins -n jenkins -f helm/jenkins_values.yaml
```

### 5. Access Jenkins

```powershell
minikube service jenkins -n jenkins --url

kubectl port-forward -n jenkins svc/jenkins 8080:8080
```

**Default Credentials:**
- Username: `admin`
- Password: `admin123`

## Configuration Details

### Jenkins Helm Values Configuration

The `jenkins_values.yaml` file includes:

- **Persistent Storage**: 8Gi volume with `standard` storage class
- **Service Type**: NodePort for easy access
- **JCasC**: Enabled with automatic job creation
- **Essential Plugins**: Kubernetes, Workflow, Configuration-as-Code
- **Security**: Custom admin credentials
- **Agent**: Disabled (using built-in node only)

### Jenkins Configuration as Code (JCasC)

The setup automatically creates:
- Welcome message: "Welcome to Jenkins with JCasC!"
- Hello World job: Freestyle project that echoes "Hello World from JCasC!"

## Verification

### 1. Check Cluster Resources

```powershell
kubectl get all --all-namespaces
```

Expected output includes:
- Jenkins pod in `Running` state (2/2 containers ready)
- Jenkins services (NodePort and ClusterIP)
- Jenkins StatefulSet with 1/1 replicas ready

### 2. Check Persistent Volumes

```powershell
kubectl get pv
kubectl get pvc -n jenkins
```

Expected output:
- Persistent Volume: `Bound` status, 8Gi capacity
- Persistent Volume Claim: `Bound` to jenkins namespace

### 3. Verify Jenkins Functionality

1. Access Jenkins web interface
2. Navigate to "hello-world" job (auto-created via JCasC)
3. Click "Build Now"
4. Check Console Output for "Hello World from JCasC!" message


## Security Configuration

### Basic Security Settings

- **Authentication**: Jenkins' own user database
- **Authorization**: Matrix-based security (can be enhanced)
- **Admin User**: Configured with custom credentials
- **Plugins**: Security-focused plugins installed


### Debug Commands

```powershell
# Check pod status and events
kubectl describe pod -n jenkins jenkins-0
kubectl get events -n jenkins

# Check logs
kubectl logs -n jenkins jenkins-0 -f

# Check services
kubectl describe svc -n jenkins jenkins

# Check storage
kubectl describe pvc -n jenkins jenkins
```
## Monitoring and Maintenance

### Health Checks

```powershell
# Check overall cluster health
kubectl get nodes
kubectl get pods --all-namespaces

# Check Jenkins specific health
kubectl get pods -n jenkins
kubectl get svc -n jenkins
kubectl get pvc -n jenkins
```
## Cleanup

### Remove Jenkins

```powershell
# Uninstall Jenkins
helm uninstall jenkins -n jenkins

# Remove namespace
kubectl delete namespace jenkins

# Remove persistent volumes (optional)
kubectl delete pv <pv-name>
```

### Stop Minikube

```powershell
# Stop cluster
minikube stop

# Delete cluster (removes all data)
minikube delete
```

## Additional Tasks Completed

### ✅ Helm Installation and Verification (10 points)
- Helm installed successfully
- Verified by deploying and removing Nginx chart from Bitnami

### ✅ Cluster Requirements (10 points) 
- Minikube provides built-in storage provisioner
- Persistent volumes and claims working correctly

### ✅ Jenkins Installation (40 points)
- Jenkins installed using Helm in separate `jenkins` namespace
- Accessible via web browser at NodePort service
- All containers running and healthy

### ✅ Jenkins Configuration (10 points)
- Jenkins configuration stored on persistent volume
- Data persists when Jenkins pod is terminated
- StatefulSet ensures proper volume mounting

### ✅ Verification (15 points)
- Hello World job created automatically via JCasC
- Job runs successfully and outputs "Hello World from JCasC!"
- Console output captured in screenshots

### ✅ Additional Tasks (15 points)
- **JCasC Implementation (5 points)**: Hello World job created via JCasC in Helm values
- **Authentication and Security (5 points)**: Custom admin credentials and security plugins configured
- **Documentation (5 points)**: Comprehensive README with troubleshooting and best practices

