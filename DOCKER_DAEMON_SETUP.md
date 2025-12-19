# Docker Daemon 설정 - Harbor Insecure Registry

## 문제
Jenkins에서 Harbor에 HTTP로 접근할 때 "http: server gave HTTP response to HTTPS client" 오류 발생

## 해결 방법

Kubernetes 노드의 Docker daemon 설정에 insecure registry를 추가해야 합니다.

### 각 노드에서 실행:

```bash
# 1. 기존 daemon.json 백업
sudo cp /etc/docker/daemon.json /etc/docker/daemon.json.bak 2>/dev/null || echo '{}' | sudo tee /etc/docker/daemon.json

# 2. insecure registry 추가
sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
  "insecure-registries": ["192.168.56.200:30002"]
}
EOF

# 3. Docker daemon 재시작
sudo systemctl restart docker
```

### 또는 모든 노드에 한 번에 적용:

```bash
# 각 노드에 SSH 접속하여 위 명령어 실행
for node in 192.168.56.200 192.168.56.201 192.168.56.202 192.168.56.203; do
  ssh $node "sudo tee /etc/docker/daemon.json > /dev/null <<'EOF'
{
  \"insecure-registries\": [\"192.168.56.200:30002\"]
}
EOF
sudo systemctl restart docker"
done
```

### 확인:

```bash
docker info | grep -i insecure
```

## 참고
- 이 설정은 호스트 노드의 Docker daemon에 적용됩니다
- Jenkins 컨테이너는 호스트의 Docker 소켓을 사용하므로 이 설정이 필요합니다

