# Kyverno(정책 엔진) 설치 가이드

## 1. 사전 준비
- nfs-pvc가 반드시 존재해야 함(정책 데이터 저장 시 필요)

## 2. 설치 방법

1. Helm 저장소 추가
```bash
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update
```

2. values.yaml 커스터마이즈 후 설치
```bash
helm install kyverno kyverno/kyverno \
  --namespace kyverno \
  --create-namespace \
  -f values.yaml
```

3. 샘플 정책 적용(선택)
```bash
# 예시: 모든 파드에 app 라벨 강제 정책
kubectl apply -f sample-policy.yaml
```

## 3. 참고
- Kyverno는 기본적으로 ClusterIP로 관리(외부 오픈 불필요)
- 샘플 정책은 values.yaml 또는 별도 yaml로 관리 권장
- 필요시 values.yaml에서 리소스/기능 추가 가능
