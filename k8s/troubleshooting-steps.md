# Kubernetes 클러스터 복구 단계

현재 클러스터에 CoreDNS와 kube-proxy와 같은 핵심 네트워킹 컴포넌트가 누락되어 있습니다. 
다음 단계를 따라 클러스터를 복구하세요:

1. Docker Desktop의 Kubernetes 재설정:
   - Docker Desktop을 열고
   - Settings > Kubernetes로 이동
   - "Reset Kubernetes Cluster" 버튼 클릭
   - "Apply & Restart" 클릭

2. 클러스터 재설정 후 확인할 사항:
   ```bash
   # 모든 시스템 파드가 실행 중인지 확인
   kubectl get pods -n kube-system
   
   # CoreDNS와 kube-proxy가 존재하는지 확인
   kubectl get pods -n kube-system | grep -E 'coredns|kube-proxy'
   
   # 시스템 서비스가 실행 중인지 확인
   kubectl get svc -n kube-system
   ```

3. 클러스터가 정상화된 후:
   - RBAC 설정 다시 적용
   - NFS Provisioner 재배포

위 과정을 완료한 후 NFS Provisioner를 다시 설정하면 정상적으로 작동할 것으로 예상됩니다.

