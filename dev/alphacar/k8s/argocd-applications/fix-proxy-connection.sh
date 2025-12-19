#!/bin/bash
echo "=== ArgoCD 프록시 설정 확인 및 수정 ==="
echo ""

echo "1. ArgoCD ConfigMap 확인:"
kubectl get configmap -n argocd argocd-cm -o yaml | grep -A 10 -i proxy || echo "프록시 설정 없음"

echo ""
echo "2. ArgoCD repo-server Pod 확인:"
kubectl get pods -n argocd | grep repo-server

echo ""
echo "3. repo-server 환경 변수 확인:"
REPO_POD=$(kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-repo-server -o jsonpath='{.items[0].metadata.name}')
if [ ! -z "$REPO_POD" ]; then
    echo "Repo-server Pod: $REPO_POD"
    kubectl get pod -n argocd $REPO_POD -o yaml | grep -A 5 -i proxy || echo "프록시 환경 변수 없음"
else
    echo "repo-server Pod를 찾을 수 없습니다"
fi

echo ""
echo "4. Repository Secret 확인:"
kubectl get secrets -n argocd -l argocd.argoproj.io/secret-type=repository

echo ""
echo "5. 네트워크 연결 테스트:"
if [ ! -z "$REPO_POD" ]; then
    echo "GitHub 연결 테스트:"
    kubectl exec -n argocd $REPO_POD -- curl -I https://github.com 2>&1 | head -5
fi
