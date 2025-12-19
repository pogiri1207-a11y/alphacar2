# ArgoCD Application 생성 에러 해결

## 에러 메시지
```
Unable to create application: application spec for alphacar-main-backend is invalid: 
InvalidSpecError: Unable to generate manifests in k8s/services/main-backend: 
rpc error: code = Unknown desc = k8s/services/main-backend: app path does not exist
```

## 원인
- Git 저장소의 `release` 브랜치에 `k8s/services/main-backend` 경로가 존재하지 않음
- ArgoCD는 원격 저장소의 특정 브랜치에서 경로를 찾는데, 해당 경로가 없어서 발생한 에러

## 해결 방법

### ✅ 완료된 작업
1. 매니페스트 파일 생성: `k8s/services/main-backend/deployment.yaml`
2. Git 커밋 완료
3. `release` 브랜치에 머지 완료

### 🔄 다음 단계: Git 푸시

**중요**: 로컬에만 있는 커밋을 원격 저장소에 푸시해야 ArgoCD가 경로를 찾을 수 있습니다!

```bash
cd /home/kevin/alphacar/dev/alphacar
git push origin release
```

### Application 다시 생성

푸시가 완료되면:

1. ArgoCD Applications 화면으로 이동
2. 기존 Application이 있다면 삭제하고 다시 생성
3. 또는 Application을 수정하여:
   - **Revision** 확인: `release` 브랜치 확인
   - **Path** 확인: `k8s/services/main-backend` 확인

## 확인 방법

### 1. GitHub/GitLab에서 확인
브라우저에서 다음 경로가 존재하는지 확인:
```
https://github.com/pogiri1207-a11y/alphacar/tree/release/k8s/services/main-backend
```

### 2. ArgoCD에서 확인
1. Repository 화면에서 저장소 클릭
2. "REFRESH" 버튼 클릭하여 최신 상태 동기화
3. Application 생성 시도

## 예상 결과

푸시 후 Application을 생성하면:
- ✅ Path 에러가 사라집니다
- ✅ ArgoCD가 매니페스트 파일을 읽을 수 있습니다
- ✅ Deployment와 Service가 생성됩니다

## 추가 문제 해결

### 여전히 경로를 찾을 수 없다면
1. Repository URL이 올바른지 확인
2. Revision (브랜치)이 `release`인지 확인
3. Path가 정확한지 확인 (앞뒤 공백 없이)
4. ArgoCD Repository에서 "REFRESH" 클릭
5. Git 저장소에 실제로 파일이 푸시되었는지 확인

### 매니페스트 파일 형식 에러
- YAML 문법 확인
- ArgoCD 로그에서 상세 에러 메시지 확인

