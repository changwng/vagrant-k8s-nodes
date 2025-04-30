nohup kubectl port-forward -n kubernetes-dashboard svc/kubernetes-dashboard 8443:443 --address 0.0.0.0 > /dev/null 2>&1 &

# 1. Helm 설치
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash



# vagrant-k8s-nodes
it's just vagrant test repo for studying k8s  
if you want to see more about it  
you can read my blog
- https://iwantbaobab.tistory.com/590


git remote add origin https://github.com/changwng/vagrant-k8s-nodes

git pull origin master

git ls-remote --heads origin

git reset --hard origin/main

git branch --set-upstream-to=origin/main main



vagrant ssh k8s-master -c "mkdir -p ~/.kube && sudo cp -i /etc/kubernetes/admin.conf ~/.kube/config && sudo chown $(id -u):$(id -g) ~/.kube/config"

vagrant ssh k8s-master -c "sudo chmod 644 ~/.kube/config"

vagrant ssh k8s-master -c "kubectl get pods --all-namespaces"


vagrant ssh k8s-master -c "kubectl describe pod -n kube-system $(kubectl get pods -n kube-system | grep metrics-server | awk '{print $1}')"

![[Pasted image 20250429084433.png]]

Let me check specifically what's wrong with the metrics-server since it's showing as not Ready.
metrix server tls 해제

vagrant ssh k8s-master -c "kubectl logs -n kube-system $(kubectl get pods -n kube-system | grep metrics-server | awk '{print $1}')"


vagrant ssh k8s-node1 -c "sudo systemctl restart kubelet && sudo systemctl status kubelet"


vagrant ssh k8s-node1 -c "sudo systemctl restart kubelet && sudo systemctl status kubelet"




…/vagrant-k8s-nodes

metrics-server의 TLS 인증을 비활성화하기 위해 deployment를 수정해보겠습니다. k8s-master 노드에서 다음 명령을 실행하겠습니다:

Working directory: ~/dev/vagrant-k8s-nodes

 $ vagrant ssh k8s-master -c "kubectl patch deployment metrics-server -n kube-system --type='json' -p='[{\"op\": \"add\", \"path\": \"/spec/template/spec/containers/0/args/-\", \"value\": \"--kubelet-insecure-tls\"}]'"

deployment.apps/metrics-server patched


--- 매트릭스 서버 재시작
~/…/vagrant-k8s-nodes $ vagrant ssh k8s-master -c "kubectl rollout restart deployment metrics-server -n kube-system"


metrics-server가 재시작되었습니다. 잠시 후에 정상적으로 작동하는지 확인해보시기 바랍니다. 

vagrant ssh k8s-master -c "kubectl top nodes"
```
kubectl top nodes



sudo mkdir -p /srv/nfs/k8s/mysql
sudo chown -R 65534:65534 /srv/nfs/k8s/mysql
sudo chmod -R 775 /srv/nfs/k8s/mysql

# jenkins
sudo mkdir -p /srv/nfs/k8s/jenkins
sudo chown -R 1001:1001 /srv/nfs/k8s/jenkins
sudo chmod -R 775 /srv/nfs/k8s/jenkins


sudo chown -R 1000:1000 /srv/nfs/k8s/jenkins
sudo chmod -R 775 /srv/nfs/k8s/jenkins



--- base64 secret 추가 방법 
```
echo -n "my-secret-pw" | base64
```




mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "SHOW DATABASES;"
4. 실전 예시
sh
CopyInsert
# 1. 파드 이름 확인
kubectl get pods -n default

# 2. 파드 내부 접속
kubectl exec -it mysql-statefulset-0 -n default -- bash

# 3. SQL 파일 실행
mysql -u root -p"$MYSQL_ROOT_PASSWORD" < /docker-entrypoint-initdb.d/initdb.sql
mysql -h <mysql-service-ip> -P <port> -u root -p < your.sql


kubectl port-forward svc/mysql 3306:3306 -n default
mysql -h 127.0.0.1 -P 3306 -u root -p


-- jenkins 설치
 kubectl apply -f jenkins/sa.yaml
 kubectl apply -f jenkins/service.yaml
 kubectl apply -f jenkins/ingress/ingress.yaml
 kubectl apply -f jenkins/pv.yaml
 kubectl apply -f jenkins/pvc.yaml
 kubectl apply -f jenkins/statefulset.yaml
 kubectl apply -f jenkins/namespace.yaml
 kubectl apply -f jenkins/role.yaml
 kubectl apply -f jenkins/rolebinding.yaml



kubectl exec -it jenkins-statefulset-0 -n default -- bash

cat /var/jenkins_home/secrets/initialAdminPassword
ab32b71c28d14b31995cb191c075802c

http://192.168.56.30:30016/
admin/cw8904

sudo swapoff -a


sudo pkill -9 containerd-shim
sudo pkill -9 containerd
sudo systemctl restart containerd
sudo systemctl restart kubelet

kubectl get nodes
sudo tail -n 50 /var/log/syslog
sudo tail -n 50 /var/log/kubelet.log
sudo journalctl -u containerd | tail -n 50



changwng/egovframe-msa-edu-backend-config:latest
changwng/egovframe-msa-edu-backend-discovery:latest
changwng/egovframe-msa-edu-backend-apigateway:latest 



vagrant ssh k8s-master -c "kubectl describe node"

vagrant ssh k8s-master -c 명령어로 control-plane에 접속해서 vagrant host 머신에서 바로 kubectl 명령어 실행 가능하도록 설정해줘

----host 에서 실행 
 vagrant host에서 실행
vagrant ssh k8s-master -c "sudo cat /etc/kubernetes/admin.conf" > ./admin.conf
export KUBECONFIG=$(pwd)/admin.conf
kubectl get nodes
export KUBECONFIG=/Users/changwng/dev/vagrant-k8s-nodes/admin.conf


---- node1에서 
free -h
df -h
top -n 1 | head -20

vagrant reload k8s-node1
vagrant reload k8s-node2

kubectl logs discovery-deployment-5f78df5887-xsptc

-- 멈춤 처리 

kubectl scale deployment reserve-check-service-deployment --replicas=0

kubectl scale deployment reserve-item-service-deployment --replicas=0

kubectl scale deployment reserve-request-service-deployment --replicas=0

kubectl scale deployment frontend-portal-deployment --replicas=0



kubectl logs discovery-deployment-5f78df5887-xsptc



192.168.56.31 discovery.local
echo '192.168.56.31 discovery.local' | sudo tee -a /etc/hosts
echo '192.168.56.31 discovery.localhost' | sudo tee -a /etc/hosts


kubectl get pods -l app=config
kubectl exec -it config-deployment-758d7d7d76-np5zt -- /bin/sh

cat /config/application.yml
cat /config/application.properties

curl http://config.default.svc.cluster.local:8888/apigateway/default 


busybox 등 테스트 파드에서 nslookup/dig로 확인 dns 문제 확인 처리 



kubectl run -it --rm dns-test --image=busybox --restart=Never -- sh
nslookup config.default.svc.cluster.local
ping config.default.svc.cluster.local
cat /etc/resolv.conf

-- 실테스트 여부 확인 
wget --spider --timeout=2 http://config.default.svc.cluster.local:8888/actuator/health
curl -I http://config.default.svc.cluster.local:8888/actuator/health




kubectl exec -it apigateway-deployment-9d4f4db5d-9x9hq -- printenv | grep CONFIG

curl -I http://config.default.svc.cluster.local:8888/actuator/health




vagrant@k8s-master:~$ kubectl logs -n kube-system -l k8s-app=kube-dns
[ERROR] plugin/errors: 2 elasticsearch.default.svc.cluster.local.localdomain. A: read udp 20.96.235.202:50954->172.16.223.2:53: i/o timeout



. iptables 및 네트워크 정책 확인
Vagrant 환경에서는 VM 간 네트워크 라우팅, 방화벽(iptables) 설정이 올바른지 확인
sudo iptables -L -n
 등으로 포트 53 (DNS) 관련 차단이 있는지 확인
6. Vagrant/VM 네트워크 설정 확인
VM이 브리지/네트워크 어댑터를 통해 서로 통신 가능한지 확인
host-only 또는 NAT 설정이 DNS 트래픽을 차단하지 않는지 확인
요약
CoreDNS가 질의하는 172.16.223.2:53 DNS 서버로 통신이 안 되어 파드 간 서비스 이름 해석이 불가
네트워크 플러그인(CNI), VM 네트워크, iptables, CoreDNS 설정을 모두 점검해야 함
실질적인 조치 예시
CoreDNS ConfigMap에서 forward . /etc/resolv.conf가 맞는지 확인
각 노드에서 dig @172.16.223.2 google.com 테스트
(문제시) /etc/resolv.conf의 nameserver를 8.8.8.8 등 외부 DNS로 바꿔서 CoreDNS도 변경 후 재시작(임시조치)
네트워크 플러그인 Pod, VM 네트워크 설정, 방화벽 등 점검


sudo iptables -L -n
cat /etc/resolv.conf
dig @172.16.223.2 google.com



kubectl -n kube-system exec -it discovery-deployment-5f78df5887-wm8j2 -- cat /etc/resolv.conf


2) (문제시) CoreDNS ConfigMap 수정
CoreDNS가 직접 실제 nameserver(예: 172.16.223.2, 8.8.8.8 등)로 질의하도록 ConfigMap을 아래처럼 수정
yaml
CopyInsert
forward . 172.16.223.2
또는 (외부 DNS 사용 시)

yaml
CopyInsert
forward . 8.8.8.8
ConfigMap 수정 후 CoreDNS 파드 재시작
sh
CopyInsert
kubectl -n kube-system delete pod -l k8s-app=kube-dns
3) 파드 내부에서 DNS 질의 테스트
CoreDNS 파드 내부에서 아래 명령으로 DNS 질의가 정상 동작하는지 확인
sh
CopyInsert
kubectl -n kube-system exec -it <coredns-pod-name> -- dig google.com
4. 결론 및 권장 액션
CoreDNS 파드 내부 /etc/resolv.conf의 nameserver 확인
필요시 CoreDNS ConfigMap의 forward를 실제 nameserver(172.16.223.2)로 변경
CoreDNS 파드 재시작
파드 내부에서 DNS 질의 정상 동작 확인
이 과정을 따르면 파드 간 DNS 해석 문제(특히 config.default.svc.cluster.local 등 서비스 이름 해석 문제)를 해결할 수 있습니다.

추가로, CoreDNS 파드 내부의 /etc/resolv.conf 내용이나, ConfigMap 변경 후 결과를 공유해주시면 더 구체적으로 안내드릴 수 있습니다!
 

coredns-668d6bf9bc-2xcvd                   1/1     Running   0             22s     20.96.36.107    k8s-node1    <none>           <none>
coredns-668d6bf9bc-x8969   

kubectl -n kube-system exec -it coredns-668d6bf9bc-2xcvd -- cat /etc/resolv.conf
kubectl -n kube-system exec -it coredns-668d6bf9bc-x8969 -- cat /etc/resolv.conf


kubectl run -n kube-system busybox --image=busybox --restart=Never -- sleep 3600
kubectl exec -n kube-system -it busybox -- cat /etc/resolv.conf
kubectl exec -n kube-system -it busybox -- nslookup google.com

 
kubectl exec -n kube-system -it busybox -- nslookup google.com
kubectl exec -n kube-system -it busybox -- nslookup config.default.svc.cluster.local

----------------------------------
### [Kubernetes DNS 문제 해결 요약]
- CoreDNS 및 kube-dns 서비스 정상 동작 확인
- 파드 내부 DNS(nameserver 10.96.0.10) → CoreDNS → 외부 nameserver(172.16.223.2)로 정상 질의
- busybox 등 유틸리티 파드에서 클러스터 서비스명, 외부 도메인 모두 정상 해석됨
- 파드 간 DNS/서비스 디스커버리 문제 완전 해결





kubectl -n kube-system edit configmap coredns
forward . 8.8.8.8

