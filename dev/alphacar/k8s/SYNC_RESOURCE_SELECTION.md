# ArgoCD Synchronize 리소스 선택 문제 해결

## 문제
"Synchronize resources: all / out of sync / none"에서 선택이 안 되는 경우

## 원인
- 리소스 목록이 아직 로드되지 않음
- Application이 매니페스트를 아직 읽지 못함
- Git 저장소에서 파일을 찾지 못함

## 해결 방법

### 방법 1: Application REFRESH 먼저 실행

1. **Synchronize 다이얼로그 닫기** (CANCEL 또는 X 클릭)

2. **Application 카드에서 "REFRESH" 버튼 클릭**
   - Application 목록 화면으로 돌아가기
   - `alphacar-main-backend` 카드에서 **"REFRESH"** 버튼 클릭
   - 잠시 기다리기 (리소스 로드 시간 필요)

3. **다시 "SYNC" 버튼 클릭**
   - REFRESH 완료 후 다시 SYNC 버튼 클릭
   - 이제 리소스 목록이 보일 것입니다

### 방법 2: Repository REFRESH

1. **Settings > Repositories**로 이동
2. 연결된 저장소에서 **"REFRESH"** 버튼 클릭
3. Application으로 돌아가서 REFRESH

### 방법 3: 리소스 목록 확인

Synchronize 다이얼로그에서:
- 리소스 목록이 표시되는지 확인
- Deployment, Service 등이 보이는지 확인
- 리소스가 보이면 각각 체크박스로 선택 가능

### 방법 4: Application 상세 화면에서 Sync

1. **Application 카드 클릭** (상세 화면으로 이동)
2. 상단의 **"SYNC"** 버튼 클릭
3. 여기서는 리소스 목록이 더 잘 보일 수 있습니다

---

## 예상되는 리소스 목록

매니페스트 파일에 따라 다음 리소스가 보여야 합니다:
- `Deployment/alphacar/main-backend`
- `Service/alphacar/main-backend`

이 리소스들을 직접 선택할 수 있어야 합니다.

---

## 단계별 가이드

### Step 1: Application REFRESH
```
1. Synchronize 다이얼로그 닫기
2. Application 카드에서 "REFRESH" 클릭
3. 10-30초 대기
```

### Step 2: 다시 Synchronize 시도
```
1. "SYNC" 버튼 클릭
2. 리소스 목록 확인
3. 리소스 선택 또는 "all" 선택
```

### Step 3: 리소스가 여전히 안 보이면
```
1. Git 저장소 확인
   - https://github.com/pogiri1207-a11y/alphacar/tree/main/k8s/services/main-backend
   - deployment.yaml 파일이 있는지 확인

2. Repository REFRESH
   - Settings > Repositories > REFRESH

3. Application 삭제 후 재생성
   - 마지막 수단
```

---

## 대안: Application 상세 화면에서 Sync

1. **Application 카드 클릭** (상세 화면)
2. 상단의 **"SYNC"** 버튼 클릭
3. 여기서는 리소스 목록이 더 명확하게 보일 수 있습니다
4. 리소스를 직접 선택하거나 "Sync All" 옵션 사용

---

## 문제가 계속되면

### 확인 사항
1. Git 저장소에 파일이 푸시되었는지 확인
   ```bash
   git push origin main
   ```

2. GitHub에서 파일 확인
   - https://github.com/pogiri1207-a11y/alphacar/tree/main/k8s/services/main-backend/deployment.yaml

3. ArgoCD 로그 확인
   - Application 상세 화면에서 에러 메시지 확인

4. 매니페스트 파일 형식 확인
   - YAML 문법 오류가 없는지 확인
   - Kubernetes 리소스 형식이 올바른지 확인

