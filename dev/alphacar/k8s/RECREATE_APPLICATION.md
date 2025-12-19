# ArgoCD Application 다시 만들기 (처음부터)

## 현재 상태 확인
- ✅ Git 저장소에 파일 존재 확인됨
- ✅ GitHub에서 `deployment.yaml` 확인됨
- ✅ Repository 연결 완료

## Application 다시 만들기 단계

### 1단계: 기존 Application 삭제 (있는 경우)

1. **Applications 화면으로 이동**
2. **기존 Application 찾기**
   - `alphacar-main-backend` Application이 있다면
3. **Application 카드에서 "DELETE" 버튼 클릭**
   - 또는 Application 상세 화면에서 "DELETE" 클릭
4. **삭제 확인**
   - 확인 다이얼로그에서 삭제 확인

### 2단계: 새 Application 생성

#### Applications 화면에서

1. **"+ NEW APP" 또는 "CREATE APPLICATION" 버튼 클릭**

#### GENERAL (일반 정보)

2. **Application Name**:
   ```
   alphacar-main-backend
   ```

3. **Project Name**:
   - 드롭다운에서 **"default"** 선택

4. **Sync Policy**:
   - **"Automatic"** 선택 (자동 동기화)
   - 또는 **"Manual"** (수동 동기화)

#### SOURCE (소스 정보) ⚠️ 중요!

5. **Repository URL**:
   - 드롭다운을 클릭
   - **"https://github.com/pogiri1207-a11y/alphacar.git"** 선택
   - 또는 직접 입력

6. **Revision**:
   ```
   main
   ```
   ⚠️ **중요**: `main` 브랜치 사용

7. **Path**:
   ```
   k8s/services/main-backend
   ```
   ⚠️ **중요**: 정확한 경로 입력 (앞뒤 공백 없이)

#### DESTINATION (대상 정보)

8. **Cluster URL**:
   ```
   https://kubernetes.default.svc
   ```
   - 드롭다운에서 선택하거나 기본값 사용

9. **Namespace**:
   ```
   alphacar
   ```
   - 네임스페이스가 없으면 자동 생성됨

### 3단계: CREATE 버튼 클릭

10. **모든 정보 입력 확인**
11. **"CREATE" 또는 "CREATE APPLICATION" 버튼 클릭**

### 4단계: Application 상태 확인

12. **Applications 목록에서 확인**
    - 새 Application이 나타남
    - 상태 확인 (Unknown → Synced)

### 5단계: REFRESH (필요시)

13. **Application 카드에서 "REFRESH" 버튼 클릭**
    - REFRESH TYPE: **"HARD"** 선택 권장
    - REFRESH 버튼 클릭

### 6단계: Synchronize (동기화)

14. **Application 카드에서 "SYNC" 버튼 클릭**

15. **Synchronize 다이얼로그 설정**:
    - **Revision**: `main` 확인
    - **SYNCHRONIZE RESOURCES**: 
      - 리소스 목록이 보이면 각각 선택
      - 또는 "all" 선택
    - **AUTO-CREATE NAMESPACE**: 체크 ✅
    - **SYNCHRONIZE** 버튼 클릭

---

## 입력값 요약

### 필수 입력값

| 항목 | 값 |
|------|-----|
| Application Name | `alphacar-main-backend` |
| Project Name | `default` |
| Repository URL | `https://github.com/pogiri1207-a11y/alphacar.git` |
| **Revision** | **`main`** ⚠️ |
| **Path** | **`k8s/services/main-backend`** ⚠️ |
| Cluster URL | `https://kubernetes.default.svc` |
| Namespace | `alphacar` |

### 선택 입력값

| 항목 | 권장값 |
|------|--------|
| Sync Policy | `Automatic` |

---

## 체크리스트

### Application 생성 전
- [ ] 기존 Application 삭제 (있는 경우)
- [ ] Git 저장소에 파일 존재 확인
- [ ] Repository 연결 확인

### Application 생성 시
- [ ] Application Name 입력
- [ ] Project Name 선택
- [ ] Repository URL 선택
- [ ] **Revision: `main`** 입력 ⚠️
- [ ] **Path: `k8s/services/main-backend`** 입력 ⚠️
- [ ] Namespace 입력
- [ ] CREATE 버튼 클릭

### Application 생성 후
- [ ] Application 목록에 나타남 확인
- [ ] REFRESH 실행 (HARD 모드)
- [ ] Synchronize 실행
- [ ] 리소스 생성 확인

---

## 문제 해결

### "app path does not exist" 에러
1. Path 확인: `k8s/services/main-backend` (정확히)
2. Revision 확인: `main` (대소문자 구분)
3. Git 푸시 확인: `git push origin main`
4. GitHub에서 파일 확인

### REFRESH가 멈춤
1. Repository REFRESH 먼저 실행
2. HARD REFRESH 시도
3. Git 푸시 확인

### Synchronize 리소스 선택 안 됨
1. Application REFRESH 먼저 실행
2. 10-30초 대기
3. 다시 SYNC 시도

---

## 빠른 참조

### Application 생성 URL (직접 접근)
```
http://argocd-server-url/applications/new
```

### 필수 입력값 (복사용)
```
Application Name: alphacar-main-backend
Repository URL: https://github.com/pogiri1207-a11y/alphacar.git
Revision: main
Path: k8s/services/main-backend
Namespace: alphacar
```

