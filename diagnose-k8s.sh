#!/bin/bash

echo "==================================="
echo "Kubernetes Cluster Diagnostics"
echo "==================================="
echo ""

echo "1. Checking pods status..."
kubectl get pods -o wide
echo ""

echo "2. Checking services..."
kubectl get services
echo ""

echo "3. Checking nginx service details..."
kubectl describe service multi-platform-nginx
echo ""

echo "4. Checking endpoints..."
kubectl get endpoints
echo ""

echo "5. Checking nginx pod logs..."
NGINX_POD=$(kubectl get pods -l app=multi-platform-nginx -o jsonpath='{.items[0].metadata.name}')
if [ -n "$NGINX_POD" ]; then
    echo "Nginx pod: $NGINX_POD"
    kubectl logs $NGINX_POD --tail=50
else
    echo "Nginx pod not found!"
fi
echo ""

echo "6. Checking backend service pods..."
for platform in dotnet nodejs python java go websocket; do
    echo "--- $platform ---"
    POD=$(kubectl get pods -l app=multi-platform-$platform -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
    if [ -n "$POD" ]; then
        kubectl get pod $POD
        echo "Recent logs:"
        kubectl logs $POD --tail=10
    else
        echo "Pod not found!"
    fi
    echo ""
done

echo "==================================="
echo "Common Issues & Solutions:"
echo "==================================="
echo ""
echo "If EXTERNAL-IP shows <pending>:"
echo "  Desktop clusters usually don't support LoadBalancer type."
echo "  Solution: Use port-forward or NodePort"
echo ""
echo "To use port-forward (recommended for desktop):"
echo "  kubectl port-forward service/multi-platform-nginx 8080:80 8081:8081"
echo "  Then access: http://localhost:8080"
echo ""
echo "To switch to NodePort:"
echo "  kubectl patch service multi-platform-nginx -p '{\"spec\":{\"type\":\"NodePort\"}}'"
echo "  kubectl get service multi-platform-nginx"
echo ""
