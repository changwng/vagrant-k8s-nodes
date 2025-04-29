# nginx ingress controller 설치 가이드

## 설치 방법

1. Helm 저장소 추가

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
```

2. values.yaml 커스터마이즈 후 설치

```bash
helm install nginx-ingress ingress-nginx/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  -f values.yaml
```

3. IngressClass 확인

```bash
kubectl get ingressclass
```

4. Ingress 리소스 생성 시

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: example-ingress
  annotations:
    kubernetes.io/ingress.class: nginx
spec:
  rules:
    - host: example.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: example-service
                port:
                  number: 80
```

## 참고
- NodePort/LoadBalancer 미사용, 오직 Ingress(80/443)로만 오픈
- 필요 시 NFS PVC 마운트 예시 주석 참고
- admin 계정 불필요
