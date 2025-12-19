# ArgoCD EOF 오류 해결 방법

## 오류 메시지
```
Failed to load target state: failed to generate manifest for source 1 of 1: 
rpc error: code = Unknown desc = failed to list refs: EOF
```

## 문제 분석
- 모든 Application이 "Unknown" SYNC STATUS
- ArgoCD repo-server가 Git 저장소에서 매니페스트를 가져오지 못함
- 네트워크 연결 문제 또는 Repository 설정 문제

## 해결 방법

### 방법 1: repo-server 재시작 (가장 빠름)

```bash
# repo-server 재시작
kubectl rollout restart deployment -n argocd argocd-repo-server

# 재시작 완료 대기
kubectl rollout status deployment/argocd-repo-server -n argocd

# Application 새로고침
kubectl patch application -n argocd alphacar-frontend --type merge -p '{"metadata":{"annotations":{"argocd.argoproj.io/refresh":"normal"}}}'
```

### 방법 2: Repository Secret 확인 및 재생성

```bash
# Repository Secret 확인
kubectl get secrets -n argocd -l argocd.argoproj.io/secret-type=repository

# Secret 상세 확인
kubectl get secret -n argocd <repository-secret-name> -o yaml

# Secret 삭제 후 ArgoCD UI에서 재연결
kubectl get secrets -n argocd -l argocd.argoproj.io/secret-type=repository -o name | xargs kubectl delete -n argocd
```

### 방법 3: 모든 Application 일괄 새로고침

```bash
# 모든 Application 새로고침
for app in alphacar-frontend alphacar-main-backend alphacar-mypage-backend alphacar-quote-backend alphacar-search-backend alphacar-community-backend alphacar-drive-backend alphacar-aichat-backend; do
  kubectl patch application -n argocd $app --type merge -p '{"metadata":{"annotations":{"argocd.argoproj.io/refresh":"normal"}}}'
  echo "Refreshed: $app"
done
```

### 방법 4: repo-server Pod 로그 확인

```bash
# repo-server Pod 이름 확인
REPO_POD=$(kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-repo-server -o jsonpath='{.items[0].metadata.name}')

# 로그 확인
kubectl logs -n argocd $REPO_POD --tail=50

# 실시간 로그 확인 (다른 터미널에서)
kubectl logs -n argocd $REPO_POD -f
```

### 방법 5: Git 저장소 직접 테스트

```bash
# repo-server Pod에서 Git 저장소 테스트
REPO_POD=$(kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-repo-server -o jsonpath='{.items[0].metadata.name}')

# GitHub 연결 테스트
kubectl exec -n argocd $REPO_POD -- curl -I https://github.com

# Git clone 테스트
kubectl exec -n argocd $REPO_POD -- git ls-remote https://github.com/pogiri1207-a11y/alphacar.git
```

## 권장 해결 순서

1. **repo-server 재시작** (방법 1)
2. **모든 Application 새로고침** (방법 3)
3. **ArgoCD UI에서 확인**
4. **문제가 계속되면** Repository Secret 재생성 (방법 2)

## 빠른 해결 명령어 (한 번에 실행)

```bash
# 1. repo-server 재시작
kubectl rollout restart deployment -n argocd argocd-repo-server
kubectl rollout status deployment/argocd-repo-server -n argocd

# 2. 모든 Application 새로고침
for app in alphacar-frontend alphacar-main-backend alphacar-mypage-backend alphacar-quote-backend alphacar-search-backend alphacar-community-backend alphacar-drive-backend alphacar-aichat-backend; do
  kubectl patch application -n argocd $app --type merge -p '{"metadata":{"annotations":{"argocd.argoproj.io/refresh":"normal"}}}'
done

# 3. 상태 확인 (30초 후)
sleep 30
kubectl get application -n argocd -o wide
```

## 예상 결과

성공 시:
- SYNC STATUS: "Synced" 또는 "OutOfSync"
- HEALTH STATUS: "Healthy" 또는 "Degraded" (리소스 문제)
- "Unknown" 상태가 사라짐

실패 시:
- 여전히 "Unknown" 상태
- repo-server 로그 확인 필요
- Repository 연결 재확인 필요
