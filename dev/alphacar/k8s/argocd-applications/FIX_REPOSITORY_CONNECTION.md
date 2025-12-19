# ArgoCD Repository 연결 실패 해결 방법

## 현재 문제
- Repository 상태: **Failed**
- 오류: `dial tcp 20.96.175.47:8081: connect: connection refused`
- 원인: ArgoCD가 잘못된 IP 주소로 연결 시도

## 해결 방법

### 방법 1: Repository 삭제 후 재연결 (권장)

1. **ArgoCD UI에서:**
   - Settings > Repositories 메뉴
   - 실패한 Repository 찾기 (`https://github.com/pogiri1207-a11y/alphacar.git`)
   - 오른쪽 끝의 **세로 점 3개(⋮)** 클릭
   - **"DELETE"** 선택하여 삭제

2. **새로 연결:**
   - **"+CONNECT REPO"** 버튼 클릭
   - **"VIA HTTPS"** 선택
   - 다음 정보 입력:
     - **Repository URL**: `https://github.com/pogiri1207-a11y/alphacar.git`
     - **Project**: `default`
     - **Username**: (비워두기 - Public 저장소인 경우)
     - **Password**: (비워두기 - Public 저장소인 경우)
   - **"CONNECT"** 버튼 클릭

3. **연결 확인:**
   - Repository 목록에서 상태가 "Successful"로 변경되는지 확인
   - **"REFRESH LIST"** 버튼 클릭하여 새로고침

### 방법 2: EDIT 버튼으로 수정

1. **Repository 상세 페이지에서:**
   - **"EDIT"** 버튼 클릭
   - Repository URL 확인: `https://github.com/pogiri1207-a11y/alphacar.git`
   - 잘못된 설정이 있다면 수정
   - **"UPDATE"** 버튼 클릭

### 방법 3: kubectl로 Repository Secret 확인 및 수정

```bash
# Repository Secret 확인
kubectl get secrets -n argocd | grep repo

# Secret 상세 확인
kubectl get secret -n argocd <repository-secret-name> -o yaml

# 잘못된 Secret 삭제
kubectl delete secret -n argocd <repository-secret-name>
```

그 후 ArgoCD UI에서 Repository를 다시 연결하세요.

## 확인 사항

1. **Repository URL이 정확한지 확인**
   - 올바른 URL: `https://github.com/pogiri1207-a11y/alphacar.git`
   - HTTP가 아닌 HTTPS 사용 확인

2. **저장소가 Public인지 확인**
   - Public 저장소는 인증 정보 불필요
   - Private 저장소는 Personal Access Token 필요

3. **네트워크 연결 확인**
   - ArgoCD Pod가 인터넷에 접근 가능한지 확인
   ```bash
   kubectl exec -n argocd <argocd-repo-server-pod> -- curl -I https://github.com
   ```

## Repository 재연결 후

1. **Applications 새로고침**
   - Applications 메뉴로 이동
   - 각 Application의 **"REFRESH"** 버튼 클릭
   - 특히 `alphacar-quote-backend` 확인

2. **동기화 상태 확인**
   - 모든 Application이 "Healthy" 상태인지 확인
   - "OutOfSync" 상태인 경우 **"SYNC"** 버튼 클릭
