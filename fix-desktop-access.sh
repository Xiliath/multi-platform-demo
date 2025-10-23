#!/bin/bash
set -e

echo "==================================="
echo "Fixing Desktop Kubernetes Access"
echo "==================================="
echo ""

echo "Desktop Kubernetes clusters (Docker Desktop, Minikube, kind) usually"
echo "don't support LoadBalancer services like cloud providers do."
echo ""
echo "Choose your solution:"
echo "1. Port-forward (quick, temporary)"
echo "2. NodePort (persistent, requires node IP)"
echo "3. Keep LoadBalancer and show diagnostics"
echo ""
read -p "Enter choice (1-3): " choice

case $choice in
    1)
        echo ""
        echo "Starting port-forward..."
        echo "Access the application at: http://localhost:8080"
        echo "WebSocket will be available at: ws://localhost:8081"
        echo ""
        echo "Press Ctrl+C to stop"
        kubectl port-forward service/multi-platform-nginx 8080:80 8081:8081
        ;;
    2)
        echo ""
        echo "Switching to NodePort..."
        kubectl patch service multi-platform-nginx -p '{"spec":{"type":"NodePort"}}'
        echo ""
        echo "Service updated! Getting details..."
        kubectl get service multi-platform-nginx
        echo ""
        HTTP_PORT=$(kubectl get service multi-platform-nginx -o jsonpath='{.spec.ports[0].nodePort}')
        WS_PORT=$(kubectl get service multi-platform-nginx -o jsonpath='{.spec.ports[1].nodePort}')
        echo "HTTP Port: $HTTP_PORT"
        echo "WebSocket Port: $WS_PORT"
        echo ""

        # Detect cluster type and show appropriate access URL
        if command -v minikube &> /dev/null && minikube status &> /dev/null; then
            MINIKUBE_IP=$(minikube ip)
            echo "Access your application at: http://$MINIKUBE_IP:$HTTP_PORT"
        elif command -v kind &> /dev/null && kind get clusters 2>/dev/null | grep -q .; then
            echo "For kind clusters, access at: http://localhost:$HTTP_PORT"
        else
            echo "For Docker Desktop, access at: http://localhost:$HTTP_PORT"
        fi
        ;;
    3)
        echo ""
        echo "Running diagnostics..."
        ./diagnose-k8s.sh
        ;;
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac
