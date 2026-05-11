**EKS Observability Platform (End-to-End DevOps Project)**

**An end-to-end cloud-native DevOps project that provisions AWS infrastructure, deploys Kubernetes monitoring & logging, and automates everything using CI/CD.**

The entire platform is deployed automatically on every Git push using GitHub Actions
.

**📌 Project Overview**

**This project demonstrates a production-style DevOps workflow using:
**
Infrastructure as Code with Terraform
Kubernetes on Amazon Web Services (AWS)
 EKS
Monitoring with Prometheus & Grafana
Alerting with Alertmanager + SNS/Email
Centralized logging with CloudWatch
Full CI/CD automation

**🧠 Architecture**
Developer Push → GitHub Actions → Terraform Apply
        ↓
AWS Infrastructure (VPC + EKS)
        ↓
Monitoring Stack (Prometheus + Grafana)
        ↓
Application Deployment & Metrics
        ↓
Alerting & Notifications
        ↓
Centralized Logging

**🛠️ Tech Stack**
Category	Tools
Cloud	AWS (EKS, VPC, IAM, CloudWatch, SNS)
IaC	Terraform
Containers	Docker + Kubernetes
Monitoring	Prometheus, Grafana, Alertmanager
Logging	Fluent Bit + CloudWatch
CI/CD	GitHub Actions
Package Manager	Helm

**📂 Repository Structure**
eks-observability-project/
│
├── terraform/
│   ├── 01-vpc.tf
│   ├── 02-eks.tf
│   ├── 03-helm-monitoring.tf
│   ├── 04-k8s-manifests.tf
│   ├── 05-alert-rules.tf
│   ├── 06-logging.tf
│   └── values.yaml
│
├── k8s/
│   ├── deployment.yaml
│   ├── service.yaml
│   └── servicemonitor.yaml
│
├── monitoring/
│   └── alert-rules.yaml
│
└── .github/workflows/
    └── pipeline.yml
    
**⚙️ CI/CD Pipeline**

**Every push to the main branch triggers:
**
1️⃣ Terraform initializes providers
2️⃣ Terraform plans infrastructure changes
3️⃣ Terraform applies infrastructure & deployments

**This automatically:**

Creates VPC and networking
Creates EKS cluster and node group
Installs kube-prometheus-stack via Helm
Deploys Kubernetes application + ServiceMonitor
Applies Prometheus alert rules
Installs Fluent Bit for logging

No manual commands required.

**🧱 Phase Breakdown**
**Phase 1 — Infrastructure
**
Provisioned using Terraform:

VPC + Public Subnets (Free-tier friendly)
IAM roles & security groups
Amazon EKS cluster + node group
**Phase 2 — Monitoring Stack**

Installed via Helm using Terraform:

Prometheus
Grafana
Alertmanager
node-exporter
kube-state-metrics
**Phase 3 Application Monitoring
**
Deployed demo Kubernetes app:

Deployment + Service
Prometheus ServiceMonitor
Grafana dashboards
**Phase 4 — Alerting**

Configured:

Prometheus alert rules
Alertmanager notifications (SNS / Email)
**Phase 5 — Logging**

Installed:

Fluent Bit DaemonSet
AWS CloudWatch Container Insights
🚀 How to Run Locally (Optional)

**Prerequisites**

Install:

Terraform
AWS CLI
kubectl
Helm

**Configure AWS credentials:**

**aws configure
**
Run Terraform:

cd terraform
terraform init
terraform plan
terraform apply
🔐 GitHub Secrets Required

Add in repository settings:

AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_REGION
🎯 What This Project Demonstrates

✔ Infrastructure as Code
✔ Kubernetes operations
✔ Observability (metrics + logs + alerts)
✔ CI/CD automation
✔ GitOps workflow
✔ Production-style cloud architecture
