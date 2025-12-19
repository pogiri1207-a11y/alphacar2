# 왜 ArgoCD에 Application을 올려야 하나요?

## ArgoCD의 역할

ArgoCD는 **GitOps** 도구입니다. Git 저장소에 있는 Kubernetes 매니페스트 파일을 자동으로 Kubernetes 클러스터에 배포합니다.

## Application을 올리는 이유

### 1. 자동 배포 (Automated Deployment)

**수동 배포 (ArgoCD 없이):**
```bash
# 매번 수동으로 실행해야 함
kubectl apply -f k8s/services/main-backend/deployment.yaml
kubectl apply -f k8s/services/main-backend/service.yaml
```

**ArgoCD 사용:**
- Git에 푸시만 하면 자동으로 배포됨
- 수동 명령어 실행 불필요

### 2. GitOps 원칙

**GitOps란?**
- Git 저장소가 "진실의 단일 소스(Single Source of Truth)"
- 모든 인프라 설정이 Git에 저장됨
- Git 히스토리로 모든 변경사항 추적 가능

**장점:**
- ✅ 버전 관리: 모든 변경사항이 Git에 기록됨
- ✅ 롤백: 이전 버전으로 쉽게 되돌릴 수 있음
- ✅ 감사: 누가, 언제, 무엇을 변경했는지 추적 가능

### 3. CI/CD 파이프라인과의 통합

**전체 CI/CD 흐름:**

```
1. 개발자가 코드 작성
   ↓
2. Git에 커밋 & 푸시
   ↓
3. Jenkins CI 파이프라인 실행
   - 코드 빌드
   - 테스트 실행
   - SonarQube 코드 품질 검사
   - Trivy 보안 스캔
   - Docker 이미지 빌드
   - Harbor에 이미지 푸시
   ↓
4. Git에 매니페스트 파일 업데이트 (이미지 태그 변경)
   ↓
5. ArgoCD가 자동으로 감지
   ↓
6. ArgoCD가 Kubernetes에 배포
   ↓
7. Argo Rollouts로 점진적 배포 (Blue-Green, Canary)
```

**ArgoCD의 역할:**
- Jenkins가 이미지를 빌드하고 Harbor에 푸시
- Git에 매니페스트 파일 업데이트 (새 이미지 태그)
- ArgoCD가 자동으로 감지하고 Kubernetes에 배포

### 4. 자동 동기화

**ArgoCD Application 설정:**
- Sync Policy: `Automatic`
- Git 저장소에 변경사항이 있으면 자동으로 감지
- Kubernetes 클러스터와 자동으로 동기화

**예시:**
1. 개발자가 매니페스트 파일 수정
2. Git에 푸시
3. ArgoCD가 자동으로 감지 (몇 초 내)
4. Kubernetes에 자동 배포

### 5. 상태 모니터링

**ArgoCD가 제공하는 것:**
- ✅ 배포 상태 확인 (Synced / OutOfSync)
- ✅ 헬스 상태 확인 (Healthy / Degraded)
- ✅ 리소스 상태 확인 (Deployment, Service, Pod)
- ✅ 웹 UI에서 모든 것을 한눈에 확인

### 6. 롤백 용이성

**롤백 방법:**
1. Git에서 이전 버전으로 되돌리기
2. ArgoCD가 자동으로 감지
3. 이전 버전으로 자동 롤백

**수동 롤백과 비교:**
- 수동: 어떤 파일을, 어떤 버전으로 되돌려야 할지 기억해야 함
- ArgoCD: Git 히스토리만 확인하면 됨

## 실제 사용 시나리오

### 시나리오 1: 새 버전 배포

**ArgoCD 없이:**
```bash
# 1. 새 이미지 빌드
docker build -t 192.168.56.200:30002/alphacar/main:v1.2.0 .

# 2. Harbor에 푸시
docker push 192.168.56.200:30002/alphacar/main:v1.2.0

# 3. 매니페스트 파일 수정 (이미지 태그 변경)
vim k8s/services/main-backend/deployment.yaml

# 4. 수동으로 배포
kubectl apply -f k8s/services/main-backend/deployment.yaml

# 5. 배포 상태 확인
kubectl get pods -n alphacar
```

**ArgoCD 사용:**
```bash
# 1. 새 이미지 빌드 (Jenkins가 자동으로)
# 2. Harbor에 푸시 (Jenkins가 자동으로)
# 3. 매니페스트 파일 수정 (이미지 태그 변경)
vim k8s/services/main-backend/deployment.yaml

# 4. Git에 푸시
git add k8s/services/main-backend/deployment.yaml
git commit -m "Update to v1.2.0"
git push origin main

# 5. ArgoCD가 자동으로 배포 (몇 초 내)
# 6. ArgoCD UI에서 상태 확인
```

### 시나리오 2: 설정 변경

**ArgoCD 없이:**
```bash
# 1. 매니페스트 파일 수정
vim k8s/services/main-backend/deployment.yaml

# 2. 수동으로 배포
kubectl apply -f k8s/services/main-backend/deployment.yaml

# 3. 변경사항 추적 어려움
```

**ArgoCD 사용:**
```bash
# 1. 매니페스트 파일 수정
vim k8s/services/main-backend/deployment.yaml

# 2. Git에 푸시
git add k8s/services/main-backend/deployment.yaml
git commit -m "Increase replicas to 3"
git push origin main

# 3. ArgoCD가 자동으로 배포
# 4. Git 히스토리로 모든 변경사항 추적 가능
```

## CI/CD 파이프라인에서의 위치

```
┌─────────────┐
│   개발자    │
│  코드 작성  │
└──────┬──────┘
       │ git push
       ↓
┌─────────────┐
│   Jenkins   │  ← CI (Continuous Integration)
│  - 빌드     │     - 코드 빌드
│  - 테스트   │     - 테스트 실행
│  - 이미지   │     - Docker 이미지 빌드
│  - Harbor   │     - Harbor에 푸시
└──────┬──────┘
       │ 매니페스트 업데이트
       │ git push
       ↓
┌─────────────┐
│   ArgoCD    │  ← CD (Continuous Deployment)
│ Application │     - Git 저장소 모니터링
│             │     - 자동 배포
│             │     - 상태 관리
└──────┬──────┘
       │ kubectl apply
       ↓
┌─────────────┐
│ Kubernetes  │
│  클러스터   │
└─────────────┘
```

## 요약

### ArgoCD Application을 올리는 이유:

1. **자동 배포**: Git에 푸시만 하면 자동으로 배포
2. **GitOps**: Git이 모든 설정의 단일 소스
3. **CI/CD 통합**: Jenkins와 함께 완전한 파이프라인 구성
4. **상태 모니터링**: 웹 UI에서 모든 상태 확인
5. **롤백 용이**: Git 히스토리로 쉽게 롤백
6. **협업**: 팀원들이 모두 같은 방식으로 배포

### ArgoCD 없이 배포하면:

- ❌ 매번 수동으로 `kubectl apply` 실행
- ❌ 배포 상태 추적 어려움
- ❌ 롤백 복잡
- ❌ 팀원마다 다른 방식으로 배포
- ❌ 실수로 잘못된 설정 배포 가능

### ArgoCD 사용하면:

- ✅ Git에 푸시만 하면 자동 배포
- ✅ 웹 UI에서 모든 상태 확인
- ✅ Git 히스토리로 쉽게 롤백
- ✅ 팀원들이 모두 같은 방식으로 배포
- ✅ 실수 방지 (Git 리뷰 프로세스)

## 결론

ArgoCD Application을 올리는 것은:
- **자동화**: 수동 작업 최소화
- **일관성**: 모든 배포가 동일한 방식
- **추적성**: 모든 변경사항이 Git에 기록
- **안정성**: 롤백과 모니터링 용이

CI/CD 파이프라인의 마지막 단계인 **배포 자동화**를 담당합니다!

