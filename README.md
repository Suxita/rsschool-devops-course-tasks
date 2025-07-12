# Task 5: Simple Application Deployment with Helm

This project demonstrates the deployment of a simple Python Flask application to a local Kubernetes cluster (Minikube) using a Helm chart.

## Prerequisites

* **PowerShell**: For running deployment scripts on Windows.
* **Git**: For version control.
* **Docker**: For containerizing the application.
* **Minikube**: To run a local Kubernetes cluster.
* **Helm**: For managing the Kubernetes deployment.

---

## Project Structure

```
.
|   deploy.ps1
|   setup-host.ps1
|   README.md
|
+---app/
|       app.py
|       Dockerfile
|       requirements.txt
|
\---helm-chart/
    |   Chart.yaml
    |   values.yaml
    |
    \---templates/
            deployment.yaml
            ingress.yaml
            service.yaml
            _helpers.tpl
```

---

## Setup and Deployment

### Step 1: Clone the Repository

Clone this repository to your local machine.

```sh
git clone <your-repo-url>
cd <your-repo-directory>
```

### Step 2: Run the Deployment Script

Open PowerShell, navigate to the project's root directory, and execute the `deploy.ps1` script. This script automates the entire process:

1.  Starts Minikube and enables the ingress addon.
2.  Builds the `flask-app` Docker image within the Minikube environment.
3.  Creates the `flask-app` namespace in Kubernetes.
4.  Deploys the application using the Helm chart.
5.  Verifies that the deployment has rolled out successfully.

```powershell
.\deploy.ps1
```

### Step 3: Update Your Hosts File

To access the application at `http://flask-app.local`, you must map the Minikube IP to this hostname.

Run the `setup-host.ps1` script in a new **Administrator** PowerShell session.

```powershell
.\setup-host.ps1
```

### Step 4: Access the Application

Open your web browser and navigate site:

You should see the message: `Hello, World!`


---


## Cleanup

To remove the deployed application and stop the cluster, run the following commands:

```sh
# Uninstall the Helm release
helm uninstall flask-app -n flask-app

# Stop the Minikube cluster
minikube stop
```