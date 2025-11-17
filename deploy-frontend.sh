#!/bin/bash

echo "=========================================="
echo "Hospital Frontend Deployment to Kubernetes"
echo "=========================================="
echo ""

# Step 1: Start Minikube
echo "Step 1: Starting Minikube cluster..."
minikube start --driver=docker

if [ $? -ne 0 ]; then
    echo "❌ Failed to start Minikube"
    exit 1
fi

echo "✅ Minikube started successfully"
echo ""

# Step 2: Configure Docker to use Minikube's Docker daemon
echo "Step 2: Configuring Docker environment..."
eval $(minikube docker-env)
echo "✅ Docker environment configured"
echo ""

# Step 3: Build Docker image
echo "Step 3: Building frontend Docker image..."
cd /Users/yaswanth/accadamic/cicd_endsem/hospital-frontend
docker build -t hospital-frontend:latest .

if [ $? -ne 0 ]; then
    echo "❌ Failed to build Docker image"
    exit 1
fi

echo "✅ Docker image built successfully"
echo ""

# Step 4: Create namespace
echo "Step 4: Creating Kubernetes namespace..."
kubectl apply -f /Users/yaswanth/accadamic/cicd_endsem/ansible-deployment/roles/frontend/files/namespace.yaml
echo ""

# Step 5: Deploy to Kubernetes
echo "Step 5: Deploying frontend to Kubernetes..."
kubectl apply -f /Users/yaswanth/accadamic/cicd_endsem/ansible-deployment/roles/frontend/files/deployment.yaml
echo ""

# Step 6: Create service
echo "Step 6: Creating Kubernetes service..."
kubectl apply -f /Users/yaswanth/accadamic/cicd_endsem/ansible-deployment/roles/frontend/files/service.yaml
echo ""

# Step 7: Wait for deployment
echo "Step 7: Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/hospital-frontend -n hospital
echo ""

# Step 8: Get service URL
echo "=========================================="
echo "✅ Deployment completed successfully!"
echo "=========================================="
echo ""
echo "Frontend service information:"
kubectl get svc hospital-frontend -n hospital
echo ""
echo "Access the frontend at:"
minikube service hospital-frontend -n hospital --url
echo ""
echo "Or run: minikube service hospital-frontend -n hospital"
echo ""
