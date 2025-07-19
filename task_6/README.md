# CI-C# Spring Boot CI/CD Pipeline with Jenkins, Docker, and Kubernetes

This project demonstrates a complete CI/CD pipeline for a simple Spring Boot web application. The pipeline automates the build, test, security scan, containerization, and deployment processes.

## Project Structure

- `src/`: Java source code for the Spring Boot application.
- `pom.xml`: Maven project configuration.
- `Dockerfile`: Defines the Docker image for the application.
- `Jenkinsfile`: Declarative pipeline script for Jenkins.
- `helm/`: Helm chart for deploying the application to Kubernetes.
- `terraform-jenkins/`: Terraform code to provision the AWS infrastructure.

---

## Infrastructure Setup

The infrastructure is managed by Terraform and consists of:
- **VPC & Subnet**: A dedicated network for our resources.
- **EC2 Instance**: A `t2.medium` instance to host the Jenkins server.
- **IAM Role**: An EC2 instance role with ECR access.
- **Security Group**: Firewall rules to allow traffic on ports `22` (SSH) and `8080` (Jenkins).
- **ECR Repository**: A private Docker registry to store our application images.

### How to Deploy
1.  Navigate to the `terraform` directory.
2.  Initialize Terraform: `terraform init`
3.  Apply the configuration: `terraform apply`

---

## Jenkins Pipeline

The pipeline is defined in the `Jenkinsfile` and performs the following stages:

1.  **Checkout Code**: Clones the `task_6`  branch from the Git repository.
2.  **Build Application**: Compiles the source code and packages it into a `.jar` file using Maven.
3.  **Unit Tests**: Runs unit tests using `mvn test`.
4.  **SonarQube Security Scan**: Analyzes the code for vulnerabilities and code smells.
5.  **Build & Push Docker Image**: Builds a Docker image using the `Dockerfile` and pushes it to the AWS ECR repository.
6.  **Deploy to K8s with Helm**: Deploys the application to a Kubernetes cluster using the provided Helm chart.
7.  **Application Verification**: Performs a simple `curl` command to check if the application is live.

### Notifications
The pipeline is configured to send email notifications via the **Email Extension Plugin** on every build completion (success or failure).

---

## Deployment Process

1.  **Commit Code**: Push your changes to the `task_6` branch of the repository.
2.  **Pipeline Trigger**: A Jenkins webhook (or SCM polling) automatically triggers the pipeline.
3.  **Execution**: Jenkins executes all stages defined in the `Jenkinsfile`.
4.  **Verification**: Once the pipeline is complete, the application will be running in the Kubernetes cluster, accessible via a LoadBalancer service. You can get the URL with:
    `kubectl get svc spring-app`D-with-jenkins