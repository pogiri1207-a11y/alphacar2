# ArgoCD 프록시 연결 오류 해결 방법

## 오류 메시지
```
Unable to connect HTTPS repository: connection error: 
desc = "transport: Error while dialing: dial tcp 20.96.175.47:8081: 
connect: connection refused"
```

## 문제 분석
- ArgoCD가 `20.96.175.47:8081`로 연결을 시도하고 있음
- 이는 GitHub의 올바른 주소가 아님
- 프록시 설정 또는 네트워크 라우팅 문제 가능성

## 해결 방법

### 방법 1: ArgoCD ConfigMap에서 프록시 설정 확인 및 제거

1. **현재 설정 확인:**
```bash
kubectl get configmap -n argocd argocd-cm -o yaml
```

2. **프록시 설정이 있다면 제거:**
```bash
kubectl edit configmap -n argocd argocd-cm
```
- `url:`, `noProxy:` 등의 프록시 관련 설정이 있다면 주석 처리하거나 삭제

3. **repo-server 재시작:**
```bash
kubectl rollout restart deployment -n argocd argocd-repo-server
```

### 방법 2: Repository Secret 확인 및 재생성

1. **Repository Secret 확인:**
```bash
kubectl get secrets -n argocd -l argocd.argoproj.io/secret-type=repository
```

2. **잘못된 Secret 삭제:**
```bash
kubectl get secrets -n argocd -l argocd.argoproj.io/secret-type=repository -o name | xargs kubectl delete -n argocd
```

3. **ArgoCD UI에서 Repository 재연결:**
   - Settings > Repositories
   - +CONNECT REPO
   - VIA HTTPS 선택
   - Repository URL: `https://github.com/pogiri1207-a11y/alphacar.git`
   - Project: `default`
   - CONNECT

### 방법 3: repo-server Pod의 환경 변수 확인

1. **repo-server Pod 확인:**
```bash
kubectl get pods -n argocd | grep repo-server
```

2. **환경 변수 확인:**
```bash
REPO_POD=$(kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-repo-server -o jsonpath='{.items[0].metadata.name}')
kubectl get pod -n argocd $REPO_POD -o yaml | grep -A 10 env
```

3. **프록시 환경 변수 제거 (있다면):**
```bash
kubectl set env deployment/argocd-repo-server -n argocd HTTP_PROXY- HTTPS_PROXY- http_proxy- https_proxy- NO_PROXY- no_proxy-
```

### 방법 4: 네트워크 정책 확인

1. **NetworkPolicy 확인:**
```bash
kubectl get networkpolicies -n argocd
```

2. **repo-server가 인터넷에 접근할 수 있는지 확인:**
```bash
REPO_POD=$(kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-repo-server -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n argocd $REPO_POD -- curl -I https://github.com
```

## 빠른 해결 순서 (권장)

1. **Repository Secret 삭제:**
```bash
kubectl get secrets -n argocd -l argocd.argoproj.io/secret-type=repository -o name | xargs kubectl delete -n argocd
```

2. **repo-server 재시작:**
```bash
kubectl rollout restart deployment -n argocd argocd-repo-server
```

3. **ArgoCD UI에서 Repository 재연결:**
   - Settings > Repositories
   - +CONNECT REPO
   - VIA HTTPS
   - URL: `https://github.com/pogiri1207-a11y/alphacar.git`
   - CONNECT

4. **연결 확인:**
   - REFRESH LIST
   - 상태가 "Successful"인지 확인

5. **Applications 새로고침:**
   - Applications 메뉴
   - 각 Application의 REFRESH 버튼 클릭
