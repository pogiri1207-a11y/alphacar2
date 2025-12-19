# ArgoCD Repository 연결 문제 해결 방법 (단계별)

## 문제 상황
- "revision release must be resolved" 오류
- Repository 연결 실패
- Application 동기화 실패

## 해결 방법 (순서대로 실행)

### 1단계: 프록시 환경 변수 제거 (터미널에서 실행)

```bash
# repo-server의 프록시 환경 변수 제거
kubectl set env deployment/argocd-repo-server -n argocd \
  HTTP_PROXY- \
  HTTPS_PROXY- \
  http_proxy- \
  https_proxy- \
  NO_PROXY- \
  no_proxy-
```

### 2단계: repo-server 재시작

```bash
# repo-server 재시작
kubectl rollout restart deployment -n argocd argocd-repo-server

# 재시작 완료 대기 (약 30초)
kubectl rollout status deployment/argocd-repo-server -n argocd
```

### 3단계: Repository Secret 삭제

```bash
# 모든 Repository Secret 삭제
kubectl get secrets -n argocd -l argocd.argoproj.io/secret-type=repository -o name | xargs kubectl delete -n argocd
```

### 4단계: ArgoCD UI에서 Repository 재연결

1. **ArgoCD 웹 UI 접속**
   - URL: `https://192.168.56.200:30001`
   - 로그인 (admin / 비밀번호)

2. **Settings > Repositories 메뉴로 이동**
   - 왼쪽 사이드바에서 "Settings" 클릭
   - "Repositories" 클릭

3. **기존 Repository 삭제 (있다면)**
   - 실패한 Repository 찾기
   - 오른쪽 끝의 **⋮ (세로 점 3개)** 클릭
   - **"DELETE"** 선택

4. **새 Repository 연결**
   - **"+CONNECT REPO"** 버튼 클릭
   - **"VIA HTTPS"** 선택 (드롭다운에서)
   - 다음 정보 입력:
     - **Repository URL**: `https://github.com/pogiri1207-a11y/alphacar.git`
     - **Project**: `default`
     - **Username**: (비워두기 - Public 저장소인 경우)
     - **Password**: (비워두기 - Public 저장소인 경우)
   - **"CONNECT"** 버튼 클릭

5. **연결 확인**
   - **"REFRESH LIST"** 버튼 클릭
   - Repository 상태가 **"Successful"**로 변경되는지 확인
   - 빨간색 "X Failed"가 사라지고 녹색 체크 표시가 나타나야 함

### 5단계: Applications 새로고침 및 동기화

1. **Applications 메뉴로 이동**
   - 왼쪽 사이드바에서 "Applications" 클릭

2. **각 Application 새로고침**
   - `alphacar-aichat-backend` 클릭
   - **"REFRESH"** 버튼 클릭
   - **"SYNC"** 버튼 클릭 → **"SYNCHRONIZE"** 클릭
   
   - `alphacar-main-backend` 클릭
   - **"REFRESH"** 버튼 클릭
   - 상태 확인

3. **모든 Application 확인**
   - Applications 목록에서 각 Application의 상태 확인
   - "OutOfSync" 상태인 경우 **"SYNC"** 버튼 클릭

### 6단계: 문제가 계속되면 추가 확인

#### A. Git 저장소 확인
```bash
# release 브랜치가 존재하는지 확인
git ls-remote https://github.com/pogiri1207-a11y/alphacar.git | grep release
```

#### B. ArgoCD ConfigMap 확인
```bash
# ConfigMap에서 프록시 설정 확인
kubectl get configmap -n argocd argocd-cm -o yaml | grep -i proxy
```

#### C. repo-server Pod 로그 확인
```bash
# repo-server Pod 이름 확인
kubectl get pods -n argocd | grep repo-server

# 로그 확인
REPO_POD=$(kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-repo-server -o jsonpath='{.items[0].metadata.name}')
kubectl logs -n argocd $REPO_POD --tail=50 | grep -i "error\|fail\|repository"
```

#### D. 네트워크 연결 테스트
```bash
# repo-server에서 GitHub 연결 테스트
REPO_POD=$(kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-repo-server -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n argocd $REPO_POD -- curl -I https://github.com
```

## 예상 결과

### 성공 시
- Repository 상태: "Successful" (녹색 체크)
- Application Sync Status: "Synced"
- Application Health: "Healthy"
- 토폴로지에 리소스들이 표시됨

### 실패 시
- Repository 상태: "Failed" (빨간색 X)
- 오류 메시지 확인
- 위의 6단계 추가 확인 실행

## 주의사항

1. **Public 저장소인 경우**: Username과 Password는 비워두세요
2. **Private 저장소인 경우**: GitHub Personal Access Token 필요
3. **재시작 대기**: repo-server 재시작 후 최소 30초 대기
4. **순서 준수**: 위 단계를 순서대로 실행하세요
