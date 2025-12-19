# Docker Daemon 설정 - 수동 실행 가이드

## 문제
Jenkins에서 Harbor에 HTTP로 접근할 때 "http: server gave HTTP response to HTTPS client" 오류 발생

## 해결 방법

각 노드에 **직접 SSH 접속**하여 다음 명령어를 실행하세요.

### 각 노드에서 실행할 명령어:

```bash
# 1. Docker daemon 설정 파일 생성/수정
sudo tee /etc/docker/daemon.json > /dev/null <<'EOF'
{
  "insecure-registries": ["192.168.56.200:30002"]
}
EOF

# 2. Docker daemon 재시작
sudo systemctl restart docker

# 3. 확인 (192.168.56.200:30002가 표시되어야 함)
docker info | grep -i "insecure registries"
```

### 실행 순서:

1. **master 노드**에 SSH 접속
   ```bash
   ssh master
   # 또는
   ssh 192.168.56.200
   ```
   위 명령어 실행

2. **node1 노드**에 SSH 접속
   ```bash
   ssh node1
   # 또는
   ssh 192.168.56.201
   ```
   위 명령어 실행

3. **node2 노드**에 SSH 접속
   ```bash
   ssh node2
   # 또는
   ssh 192.168.56.202
   ```
   위 명령어 실행

4. **node3 노드**에 SSH 접속
   ```bash
   ssh node3
   # 또는
   ssh 192.168.56.203
   ```
   위 명령어 실행

### 확인:

모든 노드에서 설정 완료 후, Jenkins Pod에서 확인:

```bash
kubectl exec -n alphacar-cicd-ns $(kubectl get pods -n alphacar-cicd-ns -l app=jenkins -o jsonpath='{.items[0].metadata.name}') -- docker info | grep -i insecure
```

출력에 `192.168.56.200:30002`가 표시되어야 합니다.

### 완료 후:

Jenkins에서 빌드를 다시 실행하세요!

