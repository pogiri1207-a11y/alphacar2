#!/bin/bash
echo "=== Unknown 상태 Application 해결 스크립트 ==="
echo ""

echo "1. Git에 파일이 있는지 확인:"
for dir in k8s/services/*/; do
    app=$(basename $dir)
    file="$dir/deployment.yaml"
    if [ -f "$file" ]; then
        if git ls-files "$file" > /dev/null 2>&1; then
            echo "  ✅ $app: Git에 있음"
        else
            echo "  ❌ $app: Git에 없음 - 추가 필요"
        fi
    else
        echo "  ⚠️  $app: 파일 없음"
    fi
done

echo ""
echo "2. Git에 없는 파일 추가:"
git add k8s/services/*/deployment.yaml 2>/dev/null
git status k8s/services/ | head -20

echo ""
echo "3. 커밋 및 푸시 (필요시):"
echo "   git commit -m 'Add missing deployment manifests'"
echo "   git push origin release"

echo ""
echo "4. Application 새로고침:"
for app in alphacar-aichat-backend alphacar-community-backend alphacar-drive-backend alphacar-mypage-backend alphacar-quote-backend alphacar-search-backend; do
    kubectl patch application -n argocd $app --type merge -p '{"metadata":{"annotations":{"argocd.argoproj.io/refresh":"normal"}}}'
    echo "  Refreshed: $app"
done

echo ""
echo "5. 30초 후 상태 확인:"
echo "   sleep 30"
echo "   kubectl get application -n argocd -o wide"
