# PostgreSQL & pgAdmin 설치 가이드

## 1. 사전 준비
- `pgadmin.local` 도메인을 모든 VM(특히 개발 PC)에 hosts 등록
  - 예시: `192.168.56.21 pgadmin.local`
- nfs-pvc가 반드시 존재해야 함

## 2. 설치 방법

1. Helm 저장소 추가
```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```

2. values.yaml 커스터마이즈 후 설치
```bash
helm install postgresql bitnami/postgresql \
  --namespace default \
  -f values.yaml
```

3. pgAdmin Ingress 리소스 적용
```bash
kubectl apply -f pgadmin-ingress.yaml
```

## 3. 접속 정보
- pgAdmin: http://pgadmin.local
- pgAdmin ID: vagrant@pgadmin.local
- pgAdmin PW: vagrant
- PostgreSQL DB: 내부 ClusterIP로만 접근 (보안상 권장)

## 4. 참고
- 모든 데이터는 nfs-pvc에 저장됨
- TLS는 미적용(실서비스는 반드시 TLS 적용 권장)
- 필요시 values.yaml에서 리소스/기능 추가 가능


예) http://192.168.56.21:32080 (ArgoCD)
예) http://192.168.56.21:32081 (Jenkins)
예) http://192.168.56.21:32082 (Gitea)
예) http://192.168.56.21:32083 (pgAdmin)
예) http://192.168.56.21:32084 (SigNoz)