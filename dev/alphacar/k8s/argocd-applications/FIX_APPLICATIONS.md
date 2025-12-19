# Application별 동기화 문제 해결 방법

## 문제 상황
- Repository는 "Successful"로 연결됨
- 하지만 각 Application이 동기화되지 않음
- "Sync error" 또는 "OutOfSync" 상태

## 해결 방법

### 1단계: Git에 파일이 있는지 확인

```bash
cd /home/kevin/alphacar/dev/alphacar

# 모든 deployment.yaml 파일 확인
ls -la k8s/services/*/deployment.yaml
ls -la k8s/frontend/*.yaml

# Git 상태 확인
git status k8s/

# Git에 커밋되어 있는지 확인
git ls-files k8s/services/
git ls-files k8s/frontend/
```

### 2단계: 파일이 Git에 없다면 커밋 및 푸시

```bash
# 모든 k8s 파일 추가
git add k8s/

# 커밋
git commit -m "Add ArgoCD applications and deployment manifests"

# release 브랜치로 푸시
git push origin release
```

### 3단계: ArgoCD UI에서 각 Application 확인 및 동기화

#### A. alphacar-aichat-backend (Sync error)
1. Applications 메뉴에서 `alphacar-aichat-backend` 클릭
2. **"REFRESH"** 버튼 클릭
3. **"SYNC"** 버튼 클릭
4. 동기화 옵션 확인 후 **"SYNCHRONIZE"** 클릭
5. 오류 메시지 확인:
   - "revision release must be resolved" → Repository 문제
   - "path not found" → deployment.yaml 파일이 Git에 없음
   - "manifest not found" → 파일 경로가 잘못됨

#### B. alphacar-main-backend (Degraded)
1. Applications 메뉴에서 `alphacar-main-backend` 클릭
2. **"REFRESH"** 버튼 클릭
3. 토폴로지에서 리소스 상태 확인:
   - Deployment가 빨간색이면 Pod 문제
   - Service가 빨간색이면 엔드포인트 문제
4. **"EVENTS"** 탭에서 오류 확인
5. 필요시 **"SYNC"** 버튼 클릭

#### C. 다른 Application들
- 각 Application에 대해 위와 동일한 과정 반복

### 4단계: Application별 문제 해결

#### 문제 1: "path not found" 또는 "manifest not found"
**원인:** deployment.yaml 파일이 Git에 없거나 경로가 잘못됨

**해결:**
```bash
# 파일 확인
ls -la k8s/services/aichat-backend/deployment.yaml

# Git에 추가
git add k8s/services/aichat-backend/deployment.yaml
git commit -m "Add aichat-backend deployment"
git push origin release

# ArgoCD에서 REFRESH
```

#### 문제 2: "revision release must be resolved"
**원인:** Git 저장소의 release 브랜치를 찾지 못함

**해결:**
```bash
# release 브랜치 확인
git branch -a | grep release

# release 브랜치가 없다면 생성
git checkout -b release
git push origin release

# ArgoCD에서 Repository REFRESH
```

#### 문제 3: "Degraded" Health
**원인:** 리소스는 생성되었지만 정상 작동하지 않음

**해결:**
```bash
# Pod 상태 확인
kubectl get pods -n alphacar

# Pod 로그 확인
kubectl logs -n alphacar <pod-name>

# Deployment 상태 확인
kubectl get deployment -n alphacar

# Service 상태 확인
kubectl get svc -n alphacar
```

### 5단계: 모든 Application 일괄 새로고침

ArgoCD UI에서:
1. Applications 메뉴로 이동
2. 각 Application 클릭
3. **"REFRESH"** 버튼 클릭
4. **"SYNC"** 버튼 클릭 (OutOfSync인 경우)

또는 kubectl로:
```bash
# 모든 Application 새로고침
kubectl patch application -n argocd alphacar-frontend --type merge -p '{"operation":{"initiatedBy":{"username":"admin"},"sync":{"revision":"release"}}}'

# 각 Application에 대해 반복
for app in alphacar-frontend alphacar-main-backend alphacar-mypage-backend alphacar-quote-backend alphacar-search-backend alphacar-community-backend alphacar-drive-backend alphacar-aichat-backend; do
  kubectl patch application -n argocd $app --type merge -p '{"operation":{"initiatedBy":{"username":"admin"},"sync":{"revision":"release"}}}'
done
```

## 확인 체크리스트

- [ ] 모든 deployment.yaml 파일이 Git에 커밋됨
- [ ] release 브랜치가 존재하고 최신 상태
- [ ] Repository가 "Successful" 상태
- [ ] 각 Application의 REFRESH 버튼 클릭
- [ ] OutOfSync인 Application은 SYNC 버튼 클릭
- [ ] Pod가 정상 실행 중인지 확인
