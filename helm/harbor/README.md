# Harbor (도커 이미지 레지스트리) 설치 가이드

## 1. 사전 준비
- `harbor.local` 도메인을 모든 VM(특히 개발 PC)에 hosts 등록
  - 예시: `192.168.56.21 harbor.local`
- nfs-pvc가 반드시 존재해야 함

## 2. 설치 방법

1. Helm 저장소 추가
```bash
helm repo add harbor https://helm.goharbor.io
helm repo update
```

2. values.yaml 커스터마이즈 후 설치
```bash
helm install harbor harbor/harbor \
  --namespace default \
  -f values.yaml
```

3. Ingress 리소스 적용
```bash
kubectl apply -f harbor-ingress.yaml
```

## 3. 접속 정보
- URL: http://harbor.local
- admin ID: vagrant
- admin PW: vagrant

## 4. 참고
- 모든 데이터는 nfs-pvc에 저장됨
- TLS는 미적용(실서비스는 반드시 TLS 적용 권장)
- 필요시 values.yaml에서 리소스/기능 추가 가능
