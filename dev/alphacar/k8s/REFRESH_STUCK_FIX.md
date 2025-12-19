# ArgoCD REFRESH가 멈춘 경우 해결 방법

## 문제
"Refresh app(s)" 다이얼로그에서 REFRESH를 클릭했는데 진행이 안 되거나 멈춤

## 가능한 원인

### 1. Git 저장소에 파일이 푸시되지 않음 ⚠️ 가장 흔한 원인
- ArgoCD는 원격 Git 저장소에서 파일을 읽습니다
- 로컬에만 있는 파일은 ArgoCD가 찾을 수 없습니다

### 2. Repository 연결 문제
- Repository 인증 정보 오류
- 네트워크 연결 문제

### 3. 매니페스트 파일 오류
- YAML 문법 오류
- Kubernetes 리소스 형식 오류

## 해결 방법

### 방법 1: Git 푸시 확인 및 실행 ⚠️ 필수!

**가장 중요한 단계입니다!**

```bash
cd /home/kevin/alphacar/dev/alphacar

# 1. 현재 상태 확인
git status

# 2. main 브랜치로 이동
git checkout main

# 3. 푸시 안 된 커밋 확인
git log origin/main..HEAD --oneline

# 4. 푸시 실행
git push origin main
```

**GitHub에서 확인:**
브라우저에서 다음 URL로 파일이 있는지 확인:
```
https://github.com/pogiri1207-a11y/alphacar/tree/main/k8s/services/main-backend/deployment.yaml
```

### 방법 2: Repository REFRESH

1. **Settings > Repositories**로 이동
2. 연결된 저장소에서 **"REFRESH"** 버튼 클릭
3. 연결 상태 확인 (녹색 체크마크)

### 방법 3: HARD REFRESH 시도

1. **Refresh app(s)** 다이얼로그에서
2. **REFRESH TYPE**: **"HARD"** 선택
3. **REFRESH** 버튼 클릭

### 방법 4: Application 삭제 후 재생성

마지막 수단:
1. Application 삭제
2. Git 푸시 확인
3. Application 다시 생성

## 단계별 해결 가이드

### Step 1: Git 푸시 확인
```bash
# 푸시 안 된 커밋이 있는지 확인
git log origin/main..HEAD --oneline

# 있다면 푸시
git push origin main
```

### Step 2: GitHub에서 파일 확인
브라우저에서:
```
https://github.com/pogiri1207-a11y/alphacar/tree/main/k8s/services/main-backend
```
파일이 보여야 합니다!

### Step 3: Repository REFRESH
- Settings > Repositories > REFRESH

### Step 4: Application REFRESH 재시도
- REFRESH TYPE: HARD 선택
- REFRESH 클릭

## 확인 체크리스트

- [ ] Git 푸시 완료 (`git push origin main`)
- [ ] GitHub에서 파일 확인됨
- [ ] Repository 연결 상태 정상 (녹색 체크마크)
- [ ] Repository REFRESH 완료
- [ ] Application REFRESH 재시도 (HARD 모드)

## 예상 결과

푸시 후 REFRESH를 하면:
- ✅ 진행 바가 완료됩니다
- ✅ Application 상태가 업데이트됩니다
- ✅ 리소스 목록이 표시됩니다
- ✅ Synchronize가 가능해집니다

## 문제가 계속되면

### ArgoCD 로그 확인
```bash
# ArgoCD 서버 로그 확인
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server

# Application 이벤트 확인
kubectl get events -n alphacar --sort-by='.lastTimestamp'
```

### 네트워크 확인
- ArgoCD가 GitHub에 접근할 수 있는지 확인
- 방화벽/프록시 설정 확인

### 매니페스트 파일 재확인
- YAML 문법 오류 확인
- Kubernetes 리소스 형식 확인

