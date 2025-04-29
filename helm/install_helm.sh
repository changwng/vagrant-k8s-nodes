#!/bin/bash
# helm 하위 전체 서비스(Chart) 및 Ingress, NodePort 매니페스트 일괄 설치 스크립트
# 반드시 helm 디렉터리에서 실행하세요

set -e

# 설치할 차트 디렉터리 목록 (필요시 추가/수정)
CHARTS=(nginx-ingress harbor gitea jenkins argocd backstage istio prometheus grafana signoz loki postgresql kafka redis rabbitmq kyverno argo-rollouts k8sgpt)

for chart in "${CHARTS[@]}"; do
  if [ -d "$chart" ]; then
    echo "[INFO] $chart Helm 차트 배포 시작"
    if [ -f "$chart/values.yaml" ]; then
      helm upgrade --install $chart $chart/ \
        -n default --create-namespace \
        -f $chart/values.yaml
    fi
    # Ingress 리소스 적용
    if compgen -G "$chart/*-ingress.yaml" > /dev/null; then
      kubectl apply -f $chart/*-ingress.yaml
    fi
    # NodePort 서비스 리소스 적용
    if [ -f "$chart/service-NodePort.yaml" ]; then
      kubectl apply -f $chart/service-NodePort.yaml
    fi
    echo "[INFO] $chart 배포 완료"
  else
    echo "[WARN] $chart 디렉터리가 존재하지 않습니다."
  fi
done

echo "[INFO] 모든 Helm 차트, Ingress, NodePort 서비스가 배포되었습니다."
