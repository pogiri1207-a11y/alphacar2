#!/bin/bash
# Jenkins와 Harbor 서비스 상태 확인 스크립트

echo "=========================================="
echo "Jenkins & Harbor 서비스 상태 확인"
echo "=========================================="

echo ""
echo "1. Pod 상태:"
kubectl get pods -n alphacar-cicd-ns | grep -E "jenkins|harbor-nginx"

echo ""
echo "2. Service 상태:"
kubectl get svc -n alphacar-cicd-ns | grep -E "jenkins|harbor"

echo ""
echo "3. EndpointSlice 상태:"
kubectl get endpointslices -n alphacar-cicd-ns | grep -E "jenkins|harbor" | head -3

echo ""
echo "4. 접속 테스트:"
echo "Jenkins: http://192.168.56.200:32000"
echo "Harbor: http://192.168.56.200:30002"

echo ""
echo "5. Pod IP 확인:"
JENKINS_IP=$(kubectl get pods -n alphacar-cicd-ns -l app=jenkins -o jsonpath='{.items[0].status.podIP}' 2>/dev/null)
HARBOR_IP=$(kubectl get pods -n alphacar-cicd-ns -l app=harbor,component=nginx -o jsonpath='{.items[0].status.podIP}' 2>/dev/null)
echo "Jenkins Pod IP: $JENKINS_IP"
echo "Harbor nginx Pod IP: $HARBOR_IP"

echo ""
echo "=========================================="
echo "만약 접속이 안 되면:"
echo "1. 브라우저에서 직접 접속 시도"
echo "2. 방화벽 확인 (포트 32000, 30002)"
echo "3. kubectl port-forward 사용:"
echo "   kubectl port-forward -n alphacar-cicd-ns svc/jenkins-service 8080:8080"
echo "   kubectl port-forward -n alphacar-cicd-ns svc/harbor 8080:80"
echo "=========================================="

