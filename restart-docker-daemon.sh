#!/bin/bash
# Kubernetes 노드의 Docker daemon 재시작 스크립트

echo "Kubernetes 노드의 Docker daemon 재시작 중..."

# 모든 노드 가져오기
NODES=$(kubectl get nodes -o jsonpath='{.items[*].metadata.name}')

for node in $NODES; do
    echo "Processing node: $node"
    
    # 노드에 접근하여 Docker daemon 재시작
    kubectl debug node/$node -it --image=busybox --restart=Never -- sh -c "
        chroot /host systemctl restart docker
        echo 'Docker daemon restarted on $node'
    " 2>&1 | grep -v "Creating debugging pod" || echo "Failed to restart on $node"
done

echo "완료! Jenkins에서 빌드를 다시 시도하세요."

