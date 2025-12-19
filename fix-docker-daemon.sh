#!/bin/bash
# Kubernetes 노드의 Docker daemon 설정 및 재시작

echo "=========================================="
echo "Docker Daemon Insecure Registry 설정"
echo "=========================================="

# 노드 IP 목록
NODES=("192.168.56.200" "192.168.56.201" "192.168.56.202" "192.168.56.203")

for node_ip in "${NODES[@]}"; do
    echo ""
    echo "Processing node: $node_ip"
    
    # SSH로 접속하여 Docker daemon 설정
    ssh -o StrictHostKeyChecking=no root@$node_ip <<'ENDSSH'
        # daemon.json 백업
        if [ -f /etc/docker/daemon.json ]; then
            cp /etc/docker/daemon.json /etc/docker/daemon.json.bak
        fi
        
        # daemon.json 생성 또는 업데이트
        cat > /etc/docker/daemon.json <<'EOF'
{
  "insecure-registries": ["192.168.56.200:30002"]
}
EOF
        
        # Docker daemon 재시작
        systemctl restart docker
        sleep 2
        
        # 확인
        docker info | grep -i "insecure registries" || echo "Warning: Insecure registry not found"
        echo "Docker daemon restarted on $(hostname)"
ENDSSH
    
    if [ $? -eq 0 ]; then
        echo "✅ Successfully configured $node_ip"
    else
        echo "❌ Failed to configure $node_ip (SSH 접속 실패 또는 권한 없음)"
        echo "   수동으로 실행하세요:"
        echo "   ssh $node_ip"
        echo "   sudo tee /etc/docker/daemon.json > /dev/null <<'EOF'"
        echo '   {"insecure-registries": ["192.168.56.200:30002"]}'
        echo "   EOF"
        echo "   sudo systemctl restart docker"
    fi
done

echo ""
echo "=========================================="
echo "완료! Jenkins에서 빌드를 다시 시도하세요."
echo "=========================================="

