#!/bin/bash
# Docker daemon 설정 확인 및 수정 스크립트

echo "=========================================="
echo "Docker Daemon 설정 확인 및 수정"
echo "=========================================="

# Jenkins Pod가 실행 중인 노드 확인
JENKINS_NODE=$(kubectl get pods -n alphacar-cicd-ns -l app=jenkins -o jsonpath='{.items[0].spec.nodeName}' 2>/dev/null)
echo "Jenkins Pod is running on: $JENKINS_NODE"
echo ""

# 모든 노드 확인
for node in master node1 node2 node3; do
    echo "=== Checking $node ==="
    
    # daemon.json 확인
    DAEMON_JSON=$(kubectl debug node/$node -it --image=busybox --restart=Never -- sh -c "chroot /host cat /etc/docker/daemon.json 2>/dev/null" 2>&1 | grep -v "Creating debugging pod" | tail -1)
    
    if echo "$DAEMON_JSON" | grep -q "192.168.56.200:30002"; then
        echo "✅ $node: daemon.json에 insecure registry 설정됨"
    else
        echo "❌ $node: daemon.json에 insecure registry 설정 안됨"
        echo "   수동으로 설정 필요:"
        echo "   ssh $node"
        echo "   sudo tee /etc/docker/daemon.json > /dev/null <<'EOF'"
        echo '   {"insecure-registries": ["192.168.56.200:30002"]}'
        echo "   EOF"
        echo "   sudo systemctl restart docker"
    fi
    
    # Docker daemon 상태 확인
    DOCKER_STATUS=$(kubectl debug node/$node -it --image=busybox --restart=Never -- sh -c "chroot /host systemctl is-active docker" 2>&1 | grep -v "Creating debugging pod" | tail -1)
    echo "   Docker status: $DOCKER_STATUS"
    echo ""
done

echo "=========================================="
echo "중요: Jenkins Pod가 실행 중인 노드($JENKINS_NODE)에서"
echo "반드시 Docker daemon 설정을 확인하고 재시작하세요!"
echo "=========================================="

