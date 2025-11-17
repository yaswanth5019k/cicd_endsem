# Hospital Management System - Ansible Deployment

This Ansible playbook deploys the Hospital Management System frontend to Kubernetes.

## Prerequisites

- Ansible installed on the control machine
- Docker installed or will be installed by the playbook
- Sudo/root access on the target machine
- At least 2GB of free RAM for Minikube

## Project Structure

```
ansible-deployment/
├── deploy.yml                          # Main playbook
├── inventory.ini                       # Inventory file
├── ansible.cfg                         # Ansible configuration
└── roles/
    └── frontend/
        ├── tasks/
        │   └── main.yml               # Frontend deployment tasks
        ├── files/
        │   ├── namespace.yaml         # Kubernetes namespace
        │   ├── deployment.yaml        # Kubernetes deployment
        │   └── service.yaml           # Kubernetes service
        └── templates/
```

## What the Playbook Does

1. **Installs Dependencies**:
   - Docker
   - kubectl
   - Minikube

2. **Sets up Kubernetes**:
   - Starts Minikube cluster
   - Creates `hospital` namespace

3. **Builds and Deploys Frontend**:
   - Copies frontend source code
   - Builds Docker image
   - Deploys to Kubernetes with 2 replicas
   - Exposes frontend via NodePort on port 30080

## Deployment Configuration

- **Namespace**: `hospital`
- **Replicas**: 2
- **Service Type**: NodePort
- **NodePort**: 30080
- **Container Port**: 80

## How to Deploy

### 1. Navigate to the deployment directory:
```bash
cd ansible-deployment
```

### 2. Run the playbook:
```bash
ansible-playbook deploy.yml
```

Or if you need to provide sudo password:
```bash
ansible-playbook deploy.yml --ask-become-pass
```

### 3. Access the frontend:
After successful deployment, you can access the frontend at:
```bash
minikube service hospital-frontend -n hospital --url
```

Or directly at: `http://<node-ip>:30080`

## Kubernetes Manifests

### Namespace (namespace.yaml)
Creates the `hospital` namespace for all resources.

### Deployment (deployment.yaml)
- 2 replicas for high availability
- Resource limits: 256Mi memory, 200m CPU
- Liveness and readiness probes configured
- Image: `hospital-frontend:latest`

### Service (service.yaml)
- Type: NodePort
- Port: 80
- NodePort: 30080

## Useful Commands

### Check deployment status:
```bash
kubectl get deployments -n hospital
```

### Check pods:
```bash
kubectl get pods -n hospital
```

### Check service:
```bash
kubectl get svc -n hospital
```

### View logs:
```bash
kubectl logs -n hospital -l app=hospital-frontend
```

### Scale deployment:
```bash
kubectl scale deployment/hospital-frontend -n hospital --replicas=3
```

### Delete deployment:
```bash
kubectl delete namespace hospital
```

## Backend Integration

The frontend expects the backend API to be available at `http://localhost:8081`. 

To run the backend locally:
```bash
cd ../hospital-backend
./mvnw spring-boot:run
```

Make sure MySQL is running with:
- Database: `hospital`
- Username: `root`
- Password: `2300032238`

## Troubleshooting

### If Minikube fails to start:
```bash
minikube delete
minikube start --driver=docker --force
```

### If pods are not starting:
```bash
kubectl describe pod <pod-name> -n hospital
```

### To rebuild and redeploy:
```bash
# Delete existing deployment
kubectl delete deployment hospital-frontend -n hospital

# Re-run the playbook
ansible-playbook deploy.yml
```

## Notes

- The playbook uses Minikube for local Kubernetes cluster
- Docker images are built inside Minikube's Docker daemon
- Frontend is accessible via NodePort service on port 30080
- The deployment includes health checks and resource limits
