# observability

 Goal

**Build a production-style Kubernetes monitoring & logging platform using:**

Amazon EKS
Terraform (Infra as Code)
Helm (App deployment)
Prometheus + Grafana
Alertmanager (SNS + Email)
CloudWatch Logs + Container Insights
Sample microservice app

At the end you’ll have:
👉 Dashboards
👉 Alerts
👉 Logs
👉 Demo screenshots
👉 GitHub repo

🏗️** High-Level Architecture**

You will deploy:

Terraform → AWS Infrastructure
        ↓
EKS Cluster + NodeGroup + IAM + SNS
        ↓
Helm → kube-prometheus-stack
        ↓
Sample microservices app
        ↓
Metrics + Logs + Alerts + Dashboards
📦 What You Will Build

**Phase 1 — Infrastructure (Terraform)**

Create Terraform project:

observability-eks/
 ├── terraform/
 ├── helm/
 ├── app/
 └── docs/
Terraform will provision:
VPC
Subnets (public/private)
Internet Gateway
EKS Cluster
Node Group
IAM Roles (IRSA)
SNS topic (alerts)
CloudWatch Container Insights
Deliverable:

👉 terraform apply creates full cluster

**Phase 2 — Deploy Monitoring Stack (Helm)**

**Install kube-prometheus-stack:**

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

helm install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace

**This deploys automatically:**

Prometheus Operator
Prometheus Server
Grafana
Alertmanager
node-exporter
kube-state-metrics

**Verify:**

kubectl get pods -n monitoring

**Phase 3 — Enable AWS Observability**

Enable CloudWatch Container Insights
aws eks update-cluster-config \
  --region us-east-1 \
  --name observability-eks \
  --logging '{"clusterLogging":[{"types":["api","audit","authenticator","controllerManager","scheduler"],"enabled":true}]}'

Deploy CloudWatch agent (Helm or manifest).

**Now you get:**

Node metrics
Pod logs
Cluster metrics in CloudWatch

**Phase 4 — Deploy Sample Microservices App**

Deploy a demo app to generate traffic.

**Use:**

Frontend (nginx)
Backend (Python Flask API)

Create Kubernetes manifests:

app/
 ├── frontend-deployment.yaml
 ├── backend-deployment.yaml
 ├── service.yaml

Expose via LoadBalancer.

Generate traffic:

kubectl run load-generator --image=busybox -it -- /bin/sh
while true; do wget -q -O- http://frontend; done

Now metrics start flowing 📈

**Phase 5 — Configure Prometheus Scraping**

Create ServiceMonitor:

apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: backend-monitor
  namespace: monitoring
spec:
  selector:
    matchLabels:
      app: backend
  endpoints:
  - port: http
    path: /metrics

Now Prometheus scrapes your app automatically.

**Phase 6 — Build Grafana Dashboards**

Create dashboards for:

**Dashboard 1 — Kubernetes Cluster**
      Node CPU & Memory
      Pod restarts
      Network usage
**Dashboard 2 — Application Metrics**
    Request rate
    Error rate
    Latency
**Dashboard 3 — AWS Metrics**
ALB requests
Node group scaling
CPU utilization


**Phase 7 — Configure Alerts 🚨**

Create alert rules:

High CPU alert
- alert: HighPodCPU
  expr: sum(rate(container_cpu_usage_seconds_total[5m])) > 0.8
  for: 2m

Connect Alertmanager → SNS → Email.

Test alert:

kubectl run stress --image=progrium/stress -- stress --cpu 2

You should receive an email alert 🎉

**Phase 8 — Security (IRSA + RBAC)**

Create IAM role for Prometheus:

Read CloudWatch metrics
Secure service accounts

Add Kubernetes RBAC roles.

**Runtime & orchestration**

Kubernetes 1.27+ cluster (EKS, GKE, AKS, or self-managed via kubeadm)
kubectl configured with kubeconfig access to target clusters
Helm 3.x for deploying monitoring stack charts
**
Metrics & monitoring backend**

Prometheus (kube-prometheus-stack chart is the standard) — scrapes metrics from nodes, pods, and the API server
metrics-server — required for live CPU/memory data in kubectl top and the HPA
Node Exporter — DaemonSet that exposes per-node hardware metrics
kube-state-metrics — exposes Kubernetes object state (pod status, restart counts, etc.)
Grafana (optional if you're building a custom UI) — or replace with your own frontend consuming the Prometheus HTTP API

**Logging backend**

Fluent Bit or Fluentd — DaemonSet log collector that tails container logs and ships them
Loki (Grafana's log aggregation system) or Elasticsearch — log storage and query layer
If using Elasticsearch: Kibana for log search, Logstash or Filebeat as the shipper

**Alerting**

Alertmanager — ships with kube-prometheus-stack, routes alerts to PagerDuty / Slack / email
PrometheusRule CRDs — define your alert conditions (OOMKill rate, restart loops, node pressure)

**Frontend / API layer (to replace the mock data in the dashboard)**

A backend API (Node.js/Go/Python) that queries Prometheus HTTP API and the Kubernetes API server
Kubernetes API server access — either in-cluster via a ServiceAccount, or external via kubeconfig
WebSocket or SSE endpoint for streaming live logs to the UI
CORS and auth layer (OIDC/RBAC) if the dashboard is externally exposed

**RBAC & security**

ServiceAccount with ClusterRole permissions to get/list/watch pods, nodes, events, and namespaces
RBAC RoleBindings scoped appropriately per namespace if multi-tenant
NetworkPolicies if you want to restrict metric scrape paths

**Development dependencies (local)**

Node.js 18+ and npm/pnpm (if building the React/JS frontend)
Docker Desktop or a local cluster tool like kind or minikube for dev testing
k9s (optional but highly recommended) — terminal UI for sanity-checking your cluster alongside the dashboard

**Infrastructure**

Persistent storage (PVC) for Prometheus TSDB and Loki/Elasticsearch indices — at minimum 50GB for a modest cluster
Load balancer or Ingress controller (ingress-nginx or AWS ALB) to expose the dashboard externally
TLS certificate (cert-manager + Let's Encrypt or your internal CA)

The fastest path to a working stack is helm install kube-prometheus-stack (covers Prometheus + Grafana + Alertmanager + Node Exporter + kube-state-metrics in one shot) paired with helm install loki-stack for logging, then wire your custom frontend to their HTTP APIs.
