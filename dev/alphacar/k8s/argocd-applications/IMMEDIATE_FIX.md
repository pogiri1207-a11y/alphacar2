# ArgoCD Repository 연결 실패 즉시 해결 방법

## 문제 상황
- Repository를 방금 다시 만들었는데도 같은 오류 발생
- `20.96.175.47:8081`로 연결 시도 (잘못된 주소)
- ArgoCD repo-server의 프록시/네트워크 설정 문제

## 즉시 해결 방법

### 방법 1: repo-server의 프록시 환경 변수 제거 (가장 확실)

```bash
# 1. 현재 환경 변수 확인
kubectl get deployment -n argocd argocd-repo-server -o yaml | grep -i proxy

# 2. 프록시 환경 변수 제거
kubectl set env deployment/argocd-repo-server -n argocd \
  HTTP_PROXY- \
  HTTPS_PROXY- \
  http_proxy- \
  https_proxy- \
  NO_PROXY- \
  no_proxy-

# 3. repo-server 재시작
kubectl rollout restart deployment -n argocd argocd-repo-server

# 4. 재시작 완료 대기 (약 30초)
kubectl rollout status deployment/argocd-repo-server -n argocd
```

### 방법 2: ArgoCD ConfigMap 확인 및 수정

```bash
# 1. ConfigMap 확인
kubectl get configmap -n argocd argocd-cm -o yaml > /tmp/argocd-cm.yaml

# 2. 프록시 관련 설정 확인
cat /tmp/argocd-cm.yaml | grep -i proxy

# 3. 프록시 설정이 있다면 제거
kubectl edit configmap -n argocd argocd-cm
# 프록시 관련 설정(url, noProxy 등) 삭제 또는 주석 처리

# 4. repo-server 재시작
kubectl rollout restart deployment -n argocd argocd-repo-server
```

### 방법 3: Repository Secret 완전 삭제 후 재생성

```bash
# 1. 모든 Repository Secret 삭제
kubectl get secrets -n argocd -l argocd.argoproj.io/secret-type=repository -o name | xargs kubectl delete -n argocd

# 2. repo-server 재시작
kubectl rollout restart deployment -n argocd argocd-repo-server

# 3. 재시작 완료 대기
kubectl rollout status deployment/argocd-repo-server -n argocd

# 4. ArgoCD UI에서 Repository 재연결
```

### 방법 4: repo-server Pod 직접 확인

```bash
# 1. repo-server Pod 이름 확인
kubectl get pods -n argocd | grep repo-server

# 2. Pod 내부에서 GitHub 연결 테스트
REPO_POD=$(kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-repo-server -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n argocd $REPO_POD -- curl -v https://github.com 2>&1 | head -20

# 3. 환경 변수 확인
kubectl exec -n argocd $REPO_POD -- env | grep -i proxy
```

## 권장 해결 순서

1. **프록시 환경 변수 제거 및 재시작** (방법 1)
2. **Repository Secret 삭제** (방법 3)
3. **ArgoCD UI에서 Repository 재연결**
4. **연결 확인**

## 확인 명령어

```bash
# Repository 연결 상태 확인
kubectl get application -n argocd -o wide

# repo-server 로그 확인
REPO_POD=$(kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-repo-server -o jsonpath='{.items[0].metadata.name}')
kubectl logs -n argocd $REPO_POD --tail=50 | grep -i "repository\|error\|fail"
```
