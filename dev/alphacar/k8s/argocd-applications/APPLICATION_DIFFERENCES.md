# ArgoCD Application 차이점 분석

## 두 Application 비교

### alphacar-aichat-backend
- **APP HEALTH:** ✅ Healthy (녹색 하트)
- **SYNC STATUS:** ❌ Sync error (실패)
- **LAST SYNC:** "Sync error to 19e98ab" (10분 전 실패)
- **토폴로지:** 노드만 표시, 실제 리소스 없음
- **오류:** "Unable to load data: revision release must be resolved"

### alphacar-main-backend
- **APP HEALTH:** ❌ Degraded (빨간색 하트)
- **SYNC STATUS:** ✅ Sync OK (성공)
- **LAST SYNC:** "Sync OK to 19e98ab" (10분 전 성공)
- **토폴로지:** 리소스 표시됨 (main-backend SVC, main-backend deploy)
- **오류:** "Unable to load data: revision release must be resolved"

## 주요 차이점

### 1. 동기화 상태
- **aichat-backend:** 동기화 실패 (Sync error)
- **main-backend:** 동기화 성공 (Sync OK)

### 2. Health 상태
- **aichat-backend:** Healthy (애플리케이션 자체는 정상)
- **main-backend:** Degraded (리소스에 문제 있음)

### 3. 리소스 표시
- **aichat-backend:** 토폴로지에 노드만 있고 실제 리소스 없음
- **main-backend:** Service와 Deployment 리소스가 표시됨

### 4. 공통 문제
- 둘 다 "revision release must be resolved" 오류
- Git 저장소의 `release` 브랜치를 해결하지 못함

## 원인 분석

### aichat-backend가 Sync error인 이유
1. Git 저장소 연결 문제로 매니페스트를 가져오지 못함
2. `k8s/services/aichat-backend/deployment.yaml` 파일을 찾지 못함
3. Repository 연결이 실패하여 리소스를 생성하지 못함

### main-backend가 Degraded인 이유
1. 동기화는 성공했지만 리소스에 문제가 있음
2. Deployment나 Service가 정상 작동하지 않음
3. Pod가 실행되지 않거나 Health check 실패

## 해결 방법

### 공통 해결: Repository 연결 문제
1. Repository 연결 확인 및 재연결
2. `release` 브랜치가 존재하는지 확인
3. Git 저장소 접근 권한 확인

### aichat-backend 해결
1. Repository 연결 후 REFRESH
2. `k8s/services/aichat-backend/deployment.yaml` 파일이 Git에 있는지 확인
3. Application SYNC 버튼 클릭

### main-backend 해결
1. Degraded 원인 확인 (Pod 로그 확인)
2. Deployment 상태 확인
3. Service 엔드포인트 확인
