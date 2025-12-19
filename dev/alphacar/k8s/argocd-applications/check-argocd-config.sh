#!/bin/bash
echo "=== ArgoCD 설정 확인 스크립트 ==="
echo ""

echo "1. ArgoCD ConfigMap 확인:"
kubectl get configmap -n argocd argocd-cm -o yaml

echo ""
echo "2. repo-server Deployment 확인:"
kubectl get deployment -n argocd argocd-repo-server -o yaml | grep -A 20 env:

echo ""
echo "3. repo-server Pod 상태:"
kubectl get pods -n argocd | grep repo-server

echo ""
echo "4. repo-server Pod 로그 (최근 20줄):"
REPO_POD=$(kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-repo-server -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ ! -z "$REPO_POD" ]; then
    kubectl logs -n argocd $REPO_POD --tail=20 | grep -i "error\|fail\|proxy\|20.96.175.47" || echo "관련 로그 없음"
fi
