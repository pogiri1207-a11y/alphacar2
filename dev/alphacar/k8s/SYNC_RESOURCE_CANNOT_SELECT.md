# Synchronize 리소스 선택이 안 되는 경우 해결

## 문제
Synchronize 다이얼로그에서 "all / out of sync / none"을 선택할 수 없음

## 원인
리소스 목록이 아직 로드되지 않았거나, ArgoCD가 Git 저장소에서 매니페스트를 읽지 못함

## 해결 방법 (순서대로 시도)

### 방법 1: Application REFRESH (HARD 모드) ⚠️ 가장 중요!

1. **Synchronize 다이얼로그 닫기**
   - CANCEL 버튼 클릭

2. **Application 카드에서 "REFRESH" 클릭**

3. **REFRESH 다이얼로그 설정**:
   - REFRESH TYPE: **"HARD"** 선택
   - REFRESH 버튼 클릭

4. **30초-1분 대기**
   - 리소스 로드 시간 필요
   - 진행 바가 완료될 때까지 기다림

5. **다시 "SYNC" 버튼 클릭**
   - 이제 리소스 목록이 보일 것입니다

### 방법 2: Repository REFRESH

1. **Settings > Repositories**로 이동

2. **연결된 저장소 찾기**
   - `https://github.com/pogiri1207-a11y/alphacar.git`

3. **"REFRESH" 버튼 클릭**

4. **연결 상태 확인**
   - 녹색 체크마크 확인

5. **Applications로 돌아가서 REFRESH**

### 방법 3: Git 푸시 확인

ArgoCD는 원격 Git 저장소에서 파일을 읽습니다.

```bash
cd /home/kevin/alphacar/dev/alphacar

# 푸시 안 된 커밋 확인
git log origin/main..HEAD --oneline

# 있다면 푸시
git push origin main
```

**GitHub에서 확인:**
```
https://github.com/pogiri1207-a11y/alphacar/tree/main/k8s/services/main-backend/deployment.yaml
```

파일이 보여야 합니다!

### 방법 4: Application 상세 화면에서 Sync

1. **Application 카드 클릭** (상세 화면으로 이동)

2. **상단의 "SYNC" 버튼 클릭**

3. **여기서는 리소스 목록이 더 명확하게 보일 수 있습니다**

4. **리소스를 직접 선택하거나 "Sync All" 옵션 사용**

### 방법 5: Application 삭제 후 재생성

마지막 수단:

1. **Application 삭제**
2. **Git 푸시 확인**
3. **Repository REFRESH**
4. **Application 다시 생성**
5. **REFRESH (HARD 모드)**
6. **SYNC 시도**

## 단계별 체크리스트

### Step 1: 다이얼로그 닫기
- [ ] Synchronize 다이얼로그 닫기 (CANCEL)

### Step 2: REFRESH
- [ ] Application 카드에서 "REFRESH" 클릭
- [ ] REFRESH TYPE: "HARD" 선택
- [ ] REFRESH 버튼 클릭
- [ ] 30초-1분 대기

### Step 3: Repository 확인
- [ ] Settings > Repositories로 이동
- [ ] 저장소 "REFRESH" 클릭
- [ ] 연결 상태 확인 (녹색 체크마크)

### Step 4: Git 확인
- [ ] Git 푸시 확인 (`git push origin main`)
- [ ] GitHub에서 파일 확인

### Step 5: 다시 SYNC
- [ ] Application 카드에서 "SYNC" 클릭
- [ ] 리소스 목록 확인
- [ ] 리소스 선택 또는 "all" 선택

## 예상되는 리소스 목록

리소스 목록이 보이면 다음이 표시되어야 합니다:
- `Deployment/alphacar/main-backend`
- `Service/alphacar/main-backend`

각 리소스의 체크박스를 선택할 수 있어야 합니다.

## 문제가 계속되면

### ArgoCD 로그 확인
```bash
# ArgoCD 서버 로그
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server | tail -50

# Application 이벤트
kubectl get events -n alphacar --sort-by='.lastTimestamp'
```

### Application 상세 화면 확인
1. Application 카드 클릭
2. 에러 메시지 확인
3. 리소스 목록 확인

### 네트워크 확인
- ArgoCD가 GitHub에 접근할 수 있는지 확인
- 방화벽/프록시 설정 확인

## 빠른 참조

### 필수 단계
1. REFRESH (HARD 모드)
2. 30초-1분 대기
3. 다시 SYNC 시도

### 확인 사항
- Git 푸시 완료
- GitHub에서 파일 확인됨
- Repository 연결 정상
- Application REFRESH 완료

