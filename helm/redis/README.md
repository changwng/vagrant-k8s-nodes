# Redis 설치 가이드

## 1. 사전 준비
- `redis.local` 도메인을 모든 VM(특히 개발 PC)에 hosts 등록
  - 예시: `192.168.56.21 redis.local`
- nfs-pvc가 반드시 존재해야 함

## 2. 설치 방법

1. Helm 저장소 추가
```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```

2. values.yaml 커스터마이즈 후 설치
```bash
helm install redis bitnami/redis \
  --namespace default \
  -f values.yaml
```

3. Ingress 리소스 적용
```bash
kubectl apply -f redis-ingress.yaml
```

## 3. 접속 정보
- URL: http://redis.local
- Redis admin PW: vagrant

## 4. 참고
- 모든 데이터는 nfs-pvc에 저장됨
- TLS는 미적용(실서비스는 반드시 TLS 적용 권장)
- 필요시 values.yaml에서 리소스/기능 추가 가능
