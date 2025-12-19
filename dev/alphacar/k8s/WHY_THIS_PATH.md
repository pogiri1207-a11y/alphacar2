# 왜 `k8s/services/main-backend` 경로를 선택해야 하나요?

## 질문
저장소에 많은 파일이 있는데, 왜 특정 경로(`k8s/services/main-backend`)만 선택해야 하나요?

## 답변

### 1. ArgoCD는 Kubernetes 매니페스트 파일만 배포합니다

**저장소에 있는 파일들:**
```
alphacar/
├── backend/              ← 소스 코드 (배포 안 함)
├── frontend/            ← 소스 코드 (배포 안 함)
├── cicd/                ← CI/CD 설정 (배포 안 함)
├── k8s/                 ← Kubernetes 설정
│   ├── README.md        ← 문서 (배포 안 함)
│   ├── namespace/       ← 네임스페이스 설정
│   ├── backend/         ← 백엔드 매니페스트
│   ├── frontend/        ← 프론트엔드 매니페스트
│   └── services/        ← 서비스별 매니페스트
│       └── main-backend/  ← main-backend 서비스 ⭐
│           └── deployment.yaml  ← 이 파일을 배포!
└── scripts/            ← 스크립트 (배포 안 함)
```

**ArgoCD가 배포하는 것:**
- ✅ Kubernetes 매니페스트 파일 (`.yaml`, `.yml`)
- ❌ 소스 코드 (`.js`, `.py`, `.java` 등)
- ❌ 문서 파일 (`.md`, `.txt` 등)
- ❌ 설정 파일 (`.json`, `.conf` 등 - ConfigMap/Secret 제외)

### 2. 각 서비스마다 별도의 Application을 만듭니다

**여러 서비스가 있다면:**

```
Application 1: alphacar-main-backend
  Path: k8s/services/main-backend
  → main-backend 서비스 배포

Application 2: alphacar-frontend
  Path: k8s/services/frontend
  → frontend 서비스 배포

Application 3: alphacar-database
  Path: k8s/services/database
  → database 서비스 배포
```

**왜 분리하나요?**
- ✅ 각 서비스를 독립적으로 배포 가능
- ✅ 서비스별로 다른 설정 가능 (브랜치, 네임스페이스 등)
- ✅ 문제 발생 시 다른 서비스에 영향 없음

### 3. Path는 "어떤 파일들을 배포할지" 지정합니다

**Path: `k8s/services/main-backend`**

이 경로의 의미:
- 이 경로에 있는 **모든 Kubernetes 매니페스트 파일**을 배포
- `deployment.yaml`, `service.yaml`, `configmap.yaml` 등 모두 포함

**예시:**
```
k8s/services/main-backend/
├── deployment.yaml    ← Deployment 리소스
├── service.yaml       ← Service 리소스
├── configmap.yaml     ← ConfigMap 리소스
└── secret.yaml        ← Secret 리소스
```

ArgoCD는 이 경로의 **모든 YAML 파일**을 읽어서 Kubernetes에 배포합니다.

### 4. 다른 경로를 선택할 수도 있습니다

**경로 선택 예시:**

#### 옵션 1: 서비스별로 분리 (권장)
```
Application: alphacar-main-backend
Path: k8s/services/main-backend
→ main-backend만 배포
```

#### 옵션 2: 전체 백엔드 배포
```
Application: alphacar-backend
Path: k8s/backend
→ backend 디렉토리의 모든 서비스 배포
```

#### 옵션 3: 전체 k8s 디렉토리 배포
```
Application: alphacar-all
Path: k8s
→ k8s 디렉토리의 모든 리소스 배포
```

**어떤 방식을 선택하나요?**
- 서비스별로 분리: 각 서비스를 독립적으로 관리 (권장)
- 전체 배포: 모든 리소스를 한 번에 배포

### 5. 실제 사용 예시

**현재 상황:**
- `main-backend` 서비스를 배포하고 싶음
- 매니페스트 파일: `k8s/services/main-backend/deployment.yaml`

**ArgoCD Application 설정:**
```
Path: k8s/services/main-backend
```

**ArgoCD가 하는 일:**
1. Git 저장소에서 `k8s/services/main-backend/` 경로 확인
2. 이 경로의 모든 YAML 파일 읽기
3. Kubernetes 리소스로 변환
4. Kubernetes 클러스터에 배포

**결과:**
- `main-backend` Deployment 생성
- `main-backend` Service 생성
- Pod 실행

### 6. 다른 파일들은 왜 배포 안 하나요?

**소스 코드 파일:**
```
backend/src/main.js
frontend/src/App.js
```
- ❌ 배포 안 함: 이미 Docker 이미지로 빌드되어 Harbor에 있음
- ✅ 이미지: `192.168.56.200:30002/alphacar/main:latest`

**문서 파일:**
```
README.md
k8s/ARGOCD_GUIDE.md
```
- ❌ 배포 안 함: Kubernetes 리소스가 아님

**CI/CD 설정:**
```
Jenkinsfile
.github/workflows/ci.yml
```
- ❌ 배포 안 함: CI/CD 도구가 사용하는 설정

**Kubernetes 매니페스트만 배포:**
```
k8s/services/main-backend/deployment.yaml  ← 이것만 배포!
```

## 요약

### 왜 `k8s/services/main-backend` 경로를 선택하나요?

1. **이 경로에 배포할 매니페스트 파일이 있기 때문**
   - `deployment.yaml` 파일이 이 경로에 있음

2. **서비스별로 분리해서 관리하기 때문**
   - `main-backend` 서비스만 배포
   - 다른 서비스와 독립적으로 관리

3. **ArgoCD가 이 경로의 파일들을 읽기 때문**
   - Path는 "어떤 파일들을 배포할지" 지정
   - 이 경로의 모든 YAML 파일이 배포됨

### 다른 경로를 선택할 수도 있습니다

- `k8s/backend` → backend 디렉토리 전체
- `k8s` → k8s 디렉토리 전체
- `k8s/services/frontend` → frontend 서비스만

**선택 기준:**
- 서비스를 독립적으로 관리하고 싶다면: 서비스별 경로
- 모든 리소스를 한 번에 배포하고 싶다면: 상위 경로

## 결론

**왜 `k8s/services/main-backend` 경로를 선택하나요?**

→ `main-backend` 서비스를 배포하기 위한 매니페스트 파일이 그 경로에 있기 때문입니다!

ArgoCD는:
- 이 경로의 **Kubernetes 매니페스트 파일**만 읽음
- 소스 코드, 문서, 설정 파일은 무시
- 읽은 파일들을 Kubernetes에 배포

**다른 서비스를 배포하고 싶다면:**
- 별도의 Application을 만들어서 다른 Path를 지정하면 됩니다!

