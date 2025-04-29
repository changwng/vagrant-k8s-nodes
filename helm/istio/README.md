# Istio (Service Mesh) 설치 가이드

## 1. 사전 준비
- istio-system 네임스페이스가 자동 생성됨
- Istio Ingress Gateway를 통해 서비스 외부 오픈

## 2. 설치 방법

1. Helm 저장소 추가
```bash
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update
```

2. values.yaml 커스터마이즈 후 설치
```bash
helm install istio-base istio/base -n istio-system --create-namespace
helm install istiod istio/istiod -n istio-system -f values.yaml
helm install istio-ingress istio/gateway -n istio-system -f values.yaml
```

3. Ingress Gateway 확인 및 서비스 연결
```bash
kubectl get svc -n istio-system
# istio-ingressgateway의 ClusterIP, 포트 확인
```

## 3. 참고
- admin 계정 불필요
- Ingress Gateway(80/443)로만 외부 오픈
- 필요시 values.yaml에서 리소스/기능 추가 가능
- Istio 서비스 메쉬 사용법은 공식 문서 참고: https://istio.io/latest/docs/
