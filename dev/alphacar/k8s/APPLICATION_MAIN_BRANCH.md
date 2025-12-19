# ArgoCD Application 생성 (main 브랜치 사용)

## Revision 설정: `main`

ArgoCD Application을 생성할 때 **Revision**을 `main`으로 설정하세요.

## Application 생성 시 입력값

### GENERAL (일반 정보)
- **Application Name**: `alphacar-main-backend`
- **Project Name**: `default`
- **Sync Policy**: `Automatic`

### SOURCE (소스 정보)
- **Repository URL**: 
  ```
  https://github.com/pogiri1207-a11y/alphacar.git
  ```
  (드롭다운에서 선택)

- **Revision**: 
  ```
  main
  ```
  ⚠️ **중요**: `release`가 아닌 `main`을 입력하세요!

- **Path**: 
  ```
  k8s/services/main-backend
  ```
  (매니페스트 파일이 있는 경로)

### DESTINATION (대상 정보)
- **Cluster URL**: 
  ```
  https://kubernetes.default.svc
  ```
  (기본값)

- **Namespace**: 
  ```
  alphacar
  ```
  (없으면 자동 생성)

## Git 푸시

main 브랜치에 매니페스트 파일이 추가되었으니 푸시하세요:

```bash
git push origin main
```

## 확인 방법

### 1. GitHub에서 확인
브라우저에서 다음 경로가 존재하는지 확인:
```
https://github.com/pogiri1207-a11y/alphacar/tree/main/k8s/services/main-backend/deployment.yaml
```

### 2. ArgoCD에서 확인
1. Repository 화면에서 저장소 클릭
2. "REFRESH" 버튼 클릭
3. Application 생성 시 Revision에 `main` 입력

## release 브랜치와의 차이점

| 항목 | release 브랜치 | main 브랜치 |
|------|---------------|-------------|
| Revision | `release` | `main` |
| 사용 목적 | 프로덕션 배포 | 개발/최신 코드 |

main 브랜치를 사용하면:
- ✅ 최신 코드로 바로 배포 가능
- ✅ 개발 중인 변경사항도 반영
- ⚠️ 불안정한 코드가 포함될 수 있음

## 문제 해결

### "app path does not exist" 에러
1. `git push origin main` 실행 여부 확인
2. GitHub에서 파일 존재 확인
3. Revision이 `main`인지 확인 (대소문자 구분)
4. Path가 정확한지 확인: `k8s/services/main-backend`

### ArgoCD가 변경사항을 인식하지 못함
1. Repository 화면에서 "REFRESH" 클릭
2. Application에서 "REFRESH" 또는 "HARD REFRESH" 클릭
3. Sync Policy가 Automatic인지 확인

