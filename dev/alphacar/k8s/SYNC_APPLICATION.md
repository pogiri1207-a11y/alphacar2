# ArgoCD Application 동기화 (Sync) 가이드

## 현재 상태
- ✅ Application 생성 완료: `alphacar-main-backend`
- ✅ Revision: `main` 설정 완료
- ⚠️ 동기화 필요 (Synchronize 다이얼로그 열림)

## Synchronize 다이얼로그 설정

### 1. Revision 확인
- **Revision**: `main` ✅ (이미 설정됨)

### 2. SYNCHRONIZE RESOURCES 선택 ⚠️ 필수!
현재 에러: "Select at least one resource"

**선택 방법:**
- **"all"** 선택 (권장) - 모든 리소스 동기화
- 또는 **"out of sync"** 선택 - 동기화되지 않은 리소스만

### 3. AUTO-CREATE NAMESPACE 체크 ✅
- **AUTO-CREATE NAMESPACE** 체크박스 선택
- `alphacar` 네임스페이스가 없으면 자동 생성됩니다

### 4. 기타 옵션 (선택사항)
일반적으로 기본값으로 두면 됩니다:
- **PRUNE**: 체크 안 함 (기본값)
- **DRY RUN**: 체크 안 함 (실제 적용)
- **FORCE**: 체크 안 함 (기본값)

### 5. SYNCHRONIZE 버튼 클릭
모든 설정 후 **"SYNCHRONIZE"** 버튼을 클릭합니다.

---

## 단계별 체크리스트

### Synchronize 다이얼로그에서:
- [ ] Revision: `main` 확인
- [ ] **SYNCHRONIZE RESOURCES**: `all` 또는 `out of sync` 선택 ⚠️
- [ ] **AUTO-CREATE NAMESPACE**: 체크 ✅
- [ ] SYNCHRONIZE 버튼 클릭

---

## 동기화 후 확인

### 1. Application 상태 확인
- **Sync Status**: `Synced` (녹색)
- **Health Status**: `Healthy` (녹색)

### 2. 리소스 확인
Application 카드를 클릭하면:
- Deployment: `main-backend`
- Service: `main-backend`
- Pod 상태 확인

### 3. Kubernetes에서 확인
```bash
kubectl get pods -n alphacar
kubectl get svc -n alphacar
kubectl get deployment -n alphacar
```

---

## 문제 해결

### "Select at least one resource" 에러
- **SYNCHRONIZE RESOURCES**에서 `all` 또는 `out of sync` 선택 필요

### 네임스페이스 에러
- **AUTO-CREATE NAMESPACE** 체크
- 또는 수동으로 생성:
  ```bash
  kubectl create namespace alphacar
  ```

### 동기화 실패
1. Application에서 "REFRESH" 클릭
2. Repository에서 "REFRESH" 클릭
3. 다시 Synchronize 시도

### 이미지 Pull 실패
- Harbor 이미지 경로 확인: `192.168.56.200:30002/alphacar/main:latest`
- 이미지가 Harbor에 있는지 확인
- Harbor 인증 정보 확인

---

## 자동 동기화 설정

Application 생성 시 **Sync Policy**를 `Automatic`으로 설정했다면:
- Git 저장소에 변경사항이 푸시되면 자동으로 동기화됩니다
- 수동으로 Synchronize를 할 필요가 없습니다

하지만 첫 배포는 수동으로 Synchronize를 해야 할 수 있습니다.

