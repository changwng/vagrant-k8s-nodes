# ArgoRollouts(카나리/블루그린 배포) 설치 가이드

## 1. 사전 준비
- nfs-pvc가 반드시 존재해야 함(메트릭 등 데이터 저장 시 필요)

## 2. 설치 방법

1. Helm 저장소 추가
```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
```

2. values.yaml 커스터마이즈 후 설치
```bash
helm install argo-rollouts argo/argo-rollouts \
  --namespace argo-rollouts \
  --create-namespace \
  -f values.yaml
```

3. 샘플 Rollout 리소스 적용(선택)
```bash
# 예시: 카나리 배포 샘플
kubectl apply -f sample-rollout.yaml
```

## 3. 참고
- ArgoRollouts는 기본적으로 ClusterIP로 관리(외부 오픈 불필요)
- 샘플 Rollout은 values.yaml 또는 별도 yaml로 관리 권장
- 필요시 values.yaml에서 리소스/기능 추가 가능
