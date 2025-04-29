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