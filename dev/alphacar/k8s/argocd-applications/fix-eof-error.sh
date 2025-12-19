#!/bin/bash
echo "=== ArgoCD EOF 오류 해결 스크립트 ==="
echo ""

echo "1. repo-server Pod 상태 확인:"
kubectl get pods -n argocd | grep repo-server

echo ""
echo "2. repo-server Pod 로그 확인 (최근 30줄):"
REPO_POD=$(kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-repo-server -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ ! -z "$REPO_POD" ]; then
    kubectl logs -n argocd $REPO_POD --tail=30 | grep -i "error\|fail\|eof\|repository" || echo "관련 로그 없음"
else
    echo "repo-server Pod를 찾을 수 없습니다"
fi

echo ""
echo "3. Repository Secret 확인:"
kubectl get secrets -n argocd -l argocd.argoproj.io/secret-type=repository

echo ""
echo "4. repo-server에서 GitHub 연결 테스트:"
if [ ! -z "$REPO_POD" ]; then
    kubectl exec -n argocd $REPO_POD -- curl -I https://github.com 2>&1 | head -5
fi

echo ""
echo "5. Application 상태 확인:"
kubectl get application -n argocd -o wide | head -10
