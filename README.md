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


sudo pkill -9 containerd-shim
sudo pkill -9 containerd
sudo systemctl restart containerd
sudo systemctl restart kubelet

kubectl get nodes
sudo tail -n 50 /var/log/syslog
sudo tail -n 50 /var/log/kubelet.log
sudo journalctl -u containerd | tail -n 50