#!/bin/bash
echo "=== ArgoCD Repository 연결 문제 해결 스크립트 ==="
echo ""
echo "1. Repository Secret 확인:"
kubectl get secrets -n argocd | grep repo
echo ""
echo "2. Repository Secret 상세 확인:"
kubectl get secret -n argocd -l argocd.argoproj.io/secret-type=repository -o yaml
echo ""
echo "3. Application 상태 확인:"
kubectl get application -n argocd alphacar-quote-backend -o yaml | grep -A 10 "status:"
echo ""
echo "4. Repository 재연결 (필요시):"
echo "   ArgoCD UI에서 Settings > Repositories로 가서 재연결하세요"
