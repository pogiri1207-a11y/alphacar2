# Path 필드 에러 해결

## 에러 메시지
```
Unable to create application: application spec for alphacar-main-backend is invalid: 
InvalidSpecError: Unable to generate manifests in alphacar-main-backend: 
rpc error: code = Unknown desc = alphacar-main-backend: app path does not exist
```

## 원인
**Path 필드에 잘못된 값이 입력되었습니다!**

에러 메시지를 보면:
- Path에 `alphacar-main-backend`가 입력됨 (Application Name)
- 올바른 Path는 `k8s/services/main-backend` (Git 저장소 경로)

## Path 필드란?

Path는 **Git 저장소 내에서 Kubernetes 매니페스트 파일이 있는 경로**입니다.

### 올바른 Path
```
k8s/services/main-backend
```

이 경로는 GitHub에서 다음과 같이 확인할 수 있습니다:
```
https://github.com/pogiri1207-a11y/alphacar/tree/main/k8s/services/main-backend
```

### 잘못된 Path 예시
- ❌ `alphacar-main-backend` (Application Name)
- ❌ `main-backend` (경로가 아님)
- ❌ `k8s/main-backend` (잘못된 경로)
- ❌ `services/main-backend` (앞부분 누락)

## Application 생성 시 올바른 입력값

### GENERAL (일반 정보)
- **Application Name**: `alphacar-main-backend`
- **Project Name**: `default`
- **Sync Policy**: `Automatic`

### SOURCE (소스 정보) ⚠️ 중요!
- **Repository URL**: 
  ```
  https://github.com/pogiri1207-a11y/alphacar.git
  ```
- **Revision**: 
  ```
  main
  ```
- **Path**: 
  ```
  k8s/services/main-backend
  ```
  ⚠️ **중요**: Application Name이 아닌 Git 저장소 경로를 입력!

### DESTINATION (대상 정보)
- **Cluster URL**: 
  ```
  https://kubernetes.default.svc
  ```
- **Namespace**: 
  ```
  alphacar
  ```

## Path 확인 방법

### 1. GitHub에서 확인
브라우저에서 다음 URL로 접속:
```
https://github.com/pogiri1207-a11y/alphacar/tree/main/k8s/services/main-backend
```

파일이 보이면 경로가 올바른 것입니다.

### 2. Git 저장소에서 확인
```bash
cd /home/kevin/alphacar/dev/alphacar
ls -la k8s/services/main-backend/
```

`deployment.yaml` 파일이 있어야 합니다.

## Application Name vs Path

### Application Name
- ArgoCD에서 Application을 식별하는 이름
- 예: `alphacar-main-backend`
- Kubernetes 리소스 이름 규칙을 따라야 함 (소문자, 하이픈만)

### Path
- Git 저장소 내의 매니페스트 파일 경로
- 예: `k8s/services/main-backend`
- 실제 파일이 있는 경로를 입력

## 체크리스트

Application 생성 시:
- [ ] Application Name: `alphacar-main-backend` (이름)
- [ ] Path: `k8s/services/main-backend` (경로) ⚠️
- [ ] Path에 Application Name을 입력하지 않았는지 확인
- [ ] Path에 앞뒤 공백 없음
- [ ] GitHub에서 경로 확인됨

## 빠른 참조

### 올바른 입력값
```
Application Name: alphacar-main-backend
Repository URL: https://github.com/pogiri1207-a11y/alphacar.git
Revision: main
Path: k8s/services/main-backend
Namespace: alphacar
```

### Path 확인 URL
```
https://github.com/pogiri1207-a11y/alphacar/tree/main/k8s/services/main-backend/deployment.yaml
```

## 문제 해결

### "app path does not exist" 에러
1. Path 확인: `k8s/services/main-backend` (정확히)
2. GitHub에서 파일 확인
3. Git 푸시 확인: `git push origin main`
4. Revision 확인: `main` (대소문자 구분)

### Path를 찾을 수 없음
1. Git 저장소에 파일이 있는지 확인
2. 브랜치 확인 (main 브랜치에 있는지)
3. 경로 앞뒤 공백 확인
4. Repository REFRESH 실행

