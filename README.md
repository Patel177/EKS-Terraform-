# EKS Terraform Deployment Project

Deploy a Flask application on AWS EKS using Terraform and Helm with automated CI/CD via GitHub Actions.

## 📋 Project Overview

- **Infrastructure**: AWS EKS cluster with Terraform
- **Application**: Flask app deployed via Helm charts
- **CI/CD**: GitHub Actions workflow for automated deployments

## 📁 Project Structure

### 📂 **app-code/** - Application Source Code
Contains the Flask Python application that will be deployed to EKS. This is your application logic.
```
app-code/
├── app.py              # Flask application with HTTP endpoints
└── requirements.txt    # Python dependencies (Flask)
```

### 📂 **app-deploy/** - Kubernetes Deployment Configuration (Helm Chart)
Contains Helm chart that defines how the app will be deployed on Kubernetes with all necessary manifests.
```
app-deploy/
├── Chart.yaml          # Helm chart metadata
├── values.yaml         # Configuration values for deployment
└── templates/          # Kubernetes manifests
    ├── deployment.yaml # Pod deployment configuration
    ├── service.yaml    # Service exposure
    ├── ingress.yaml    # External access
    └── hpa.yaml        # Auto-scaling rules
```

### 📂 **terraform-eks/** - Infrastructure as Code
Contains Terraform configuration to provision the entire AWS EKS infrastructure (VPC, EKS cluster, security groups, IAM roles, etc.)
```
terraform-eks/
├── vpc.tf              # VPC and networking
├── eks-cluster.tf      # EKS cluster configuration
├── security-groups.tf  # Security rules
├── iam-*.tf            # IAM roles and policies
├── load-balancer-controller.tf  # Load balancer setup
├── variables.tf        # Configuration variables
├── versions.tf         # Provider versions
└── outputs.tf          # Output values
```

### 📂 **.github/workflows/** - CI/CD Pipelines
Contains GitHub Actions workflows that automate the entire deployment process.

#### **1. image-build.yml** - Docker Image Build & Push Pipeline
Builds the Flask application into a Docker image and pushes it to AWS ECR (Elastic Container Registry)
- **Trigger**: Manual workflow dispatch
- **Purpose**: Creates containerized version of the Flask app
- **Steps**:
  - Checks out code from repository
  - Authenticates with AWS
  - Logs into Amazon ECR
  - Builds Docker image from Dockerfile
  - Pushes image to ECR repository
  - Tags image with custom version
- **Input Options**: Custom image tag, ECR repository visibility (private/public)

#### **2. eks-deploy.yaml** - Infrastructure Deployment Pipeline
Provisions or destroys the entire AWS EKS infrastructure using Terraform
- **Trigger**: Manual workflow dispatch
- **Purpose**: Creates/updates/destroys EKS cluster and networking
- **Steps**:
  - Checks out code from repository
  - Sets up Terraform
  - Authenticates with AWS
  - Initializes Terraform
  - Plans/Applies/Destroys infrastructure based on user input
- **Input Options**: Action choice (plan, apply, destroy)
- **Infrastructure Created**: VPC, EKS cluster, security groups, IAM roles, load balancer controller

#### **3. app-deploy.yaml** - Application Deployment Pipeline
Deploys the Flask application to the already provisioned EKS cluster using Helm
- **Trigger**: Manual workflow dispatch
- **Purpose**: Deploys/updates Flask app on EKS cluster
- **Steps**:
  - Checks out code from repository
  - Installs kubectl and Helm tools
  - Authenticates with AWS
  - Updates kubeconfig to connect to EKS cluster
  - Deploys/upgrades Flask app using Helm chart to the namespace
- **What it does**: Runs the Helm chart from `app-deploy/` folder to deploy containers to EKS

**Pipeline Execution Order**:
1. First run `eks-deploy.yaml` with **apply** action → Creates infrastructure
2. Then run `image-build.yml` → Builds and pushes Docker image to ECR
3. Finally run `app-deploy.yaml` → Deploys application to EKS cluster

### 📄 **Dockerfile** - Container Image Configuration
Defines how to build the Docker image for the Flask application.

## 🚀 Prerequisites

Before starting, ensure you have installed:

**Local Development Tools:**
- ✅ **Terraform** (>= 1.5.7) - for infrastructure provisioning
- ✅ **AWS CLI** (latest) - for AWS interactions
- ✅ **kubectl** (latest) - for Kubernetes cluster management
- ✅ **Helm** (latest v3+) - for package management
- ✅ **Docker** (optional) - if building images locally

**AWS Requirements:**
- ✅ **AWS Account** with appropriate IAM permissions
- ✅ **AWS Access Key ID** and **Secret Access Key**
- ✅ Permissions for: EC2, EKS, VPC, IAM, CloudFormation

**GitHub Requirements:**
- ✅ **GitHub Account** with repository access
- ✅ Ability to add GitHub Secrets for CI/CD

## 📦 Infrastructure Setup

```bash
cd terraform-eks
terraform init
terraform plan
terraform apply
```

Configure kubectl:
```bash
aws eks update-kubeconfig --name neel-2025 --region eu-west-1
kubectl get nodes
```

## 🚀 Deploy Application

### Using Helm

```bash
helm upgrade --install flaskdeploy ./app-deploy \
  --namespace neel \
  --create-namespace \
  --wait
```

### Using GitHub Actions

1. Set AWS credentials in GitHub Secrets:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`

2. Trigger workflow:
   - Go to **Actions** tab
   - Select **Deploy resources on eks**
   - Click **Run workflow**

The pipeline automatically:
- Installs kubectl and Helm
- Configures AWS credentials
- Updates kubeconfig
- Deploys Helm chart to EKS

## ✅ Verify Deployment

```bash
# Check pods
kubectl get pods -n neel

# View logs
kubectl logs -f deployment/flaskdeploy -n neel

# Get service endpoint
kubectl get svc -n neel
```

## 🧹 Cleanup

```bash
# Remove Helm release
helm uninstall flaskdeploy --namespace neel

# Destroy infrastructure
cd terraform-eks
terraform destroy
```

## 📚 Key Files

| File | Purpose |
|------|---------|
| `terraform-eks/` | EKS cluster and VPC configuration |
| `app-deploy/` | Helm chart with K8s manifests |
| `.github/workflows/app-deploy.yaml` | Automated deployment workflow |
| `app-code/app.py` | Flask application |

---

**Last Updated**: January 29, 2026
