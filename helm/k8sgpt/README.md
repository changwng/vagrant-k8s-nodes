# K8sGPT(쿠버네티스 AI 진단) 설치 가이드

## 1. 사전 준비
- `k8sgpt.local` 도메인을 모든 VM(특히 개발 PC)에 hosts 등록
  - 예시: `192.168.56.21 k8sgpt.local`

## 2. 설치 방법

1. Helm 저장소 추가(공식 차트 배포처 확인 필요)
```bash
helm repo add k8sgpt https://charts.k8sgpt.ai
helm repo update
```

2. values.yaml 커스터마이즈 후 설치
```bash
helm install k8sgpt k8sgpt/k8sgpt \
  --namespace default \
  -f values.yaml
```

3. Ingress 리소스 적용
```bash
kubectl apply -f k8sgpt-ingress.yaml
```

## 3. 접속 정보
- URL: http://k8sgpt.local
- admin ID: vagrant
- admin PW: vagrant

## 4. 참고
- TLS는 미적용(실서비스는 반드시 TLS 적용 권장)
- 필요시 values.yaml에서 리소스/기능 추가 가능
