#!/bin/bash
echo "=== ArgoCD Repository 연결 문제 빠른 해결 스크립트 ==="
echo ""

echo "1. 프록시 환경 변수 제거 중..."
kubectl set env deployment/argocd-repo-server -n argocd \
  HTTP_PROXY- \
  HTTPS_PROXY- \
  http_proxy- \
  https_proxy- \
  NO_PROXY- \
  no_proxy-

echo ""
echo "2. repo-server 재시작 중..."
kubectl rollout restart deployment -n argocd argocd-repo-server

echo ""
echo "3. 재시작 완료 대기 중 (약 30초)..."
kubectl rollout status deployment/argocd-repo-server -n argocd

echo ""
echo "4. Repository Secret 삭제 중..."
kubectl get secrets -n argocd -l argocd.argoproj.io/secret-type=repository -o name | xargs kubectl delete -n argocd 2>/dev/null || echo "삭제할 Secret이 없습니다."

echo ""
echo "✅ 완료!"
echo ""
echo "다음 단계:"
echo "1. ArgoCD UI 접속: https://192.168.56.200:30001"
echo "2. Settings > Repositories"
echo "3. +CONNECT REPO 클릭"
echo "4. VIA HTTPS 선택"
echo "5. Repository URL: https://github.com/pogiri1207-a11y/alphacar.git"
echo "6. Project: default"
echo "7. CONNECT 클릭"
echo "8. Applications 메뉴에서 각 Application의 REFRESH 버튼 클릭"
