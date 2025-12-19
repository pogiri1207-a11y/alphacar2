# alphacar-quote-backend 동기화 오류 해결 방법

## 오류 메시지
```
Unable to sync alphacar-quote-backend: error resolving repo revision: 
rpc error: code = Unavailable desc = connection error: 
desc = "transport: Error while dialing: dial tcp 20.96.175.47:8081: 
connect: connection refused"
```

## 원인
ArgoCD가 Git 저장소에 연결할 수 없음 (네트워크 문제 또는 Repository 설정 문제)

## 해결 방법

### 방법 1: ArgoCD UI에서 Repository 재연결 (가장 빠름)

1. **ArgoCD 웹 UI 접속**
   - `https://192.168.56.200:30001`

2. **Settings > Repositories 메뉴로 이동**

3. **Repository 확인**
   - `https://github.com/pogiri1207-a11y/alphacar.git` 찾기
   - 상태가 "Failed" 또는 "Unknown"인지 확인

4. **재연결**
   - Repository 옆의 **"REFRESH"** 버튼 클릭
   - 또는 **"DISCONNECT"** 후 다시 **"CONNECT"**

5. **Application 새로고침**
   - Applications 메뉴로 돌아가기
   - `alphacar-quote-backend` 찾기
   - **"REFRESH"** 버튼 클릭

### 방법 2: Application 강제 동기화

1. **ArgoCD UI에서**
   - `alphacar-quote-backend` Application 클릭
   - **"SYNC"** 버튼 클릭
   - 동기화 옵션 확인 후 **"SYNCHRONIZE"** 클릭

### 방법 3: kubectl로 Application 재생성

```bash
# Application 삭제
kubectl delete application -n argocd alphacar-quote-backend

# Application 재생성
kubectl apply -f k8s/argocd-applications/quote-backend-application.yaml
```

### 방법 4: Repository Secret 확인 및 수정

```bash
# Repository Secret 확인
kubectl get secrets -n argocd | grep repo

# Secret 상세 확인
kubectl get secret -n argocd <repository-secret-name> -o yaml

# 필요시 Secret 삭제 후 재생성
kubectl delete secret -n argocd <repository-secret-name>
```

그 후 ArgoCD UI에서 Repository를 다시 연결하세요.

## 예방 방법

1. **Repository 연결 상태 정기 확인**
   - ArgoCD UI에서 Settings > Repositories 확인

2. **네트워크 연결 확인**
   - ArgoCD Pod가 인터넷에 접근 가능한지 확인
   ```bash
   kubectl exec -n argocd <argocd-repo-server-pod> -- curl -I https://github.com
   ```

3. **Application 자동 새로고침 설정**
   - Application YAML에 다음 추가:
   ```yaml
   spec:
     syncPolicy:
       syncOptions:
         - CreateNamespace=true
         - PruneLast=true
   ```

## 참고

- 다른 Application들(aichat, community, frontend 등)은 정상 작동 중
- quote-backend만 문제가 있다면 특정 경로나 파일 문제일 수 있음
- `k8s/services/quote-backend/deployment.yaml` 파일이 Git에 올바르게 커밋되었는지 확인
