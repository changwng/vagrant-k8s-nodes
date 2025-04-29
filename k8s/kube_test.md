kubectl run -it --rm test-curl --image=busybox --restart=Never -- sh
# 파드 내부에서 아래 명령 실행
wget -qO- http://config:8888/apigateway/default



kubectl exec -it config-deployment-7ff78ddf7-rcfw2 -- netstat -tnlp | grep 8888


kubectl exec -it config-deployment-7ff78ddf7-rcfw2 -- curl -v http://localhost:8888/actuator/health


kubectl exec -it config-deployment-7ff78ddf7-rcfw2 -- wget -qO- http://localhost:8888/apigateway/default


kubectl exec -it config-deployment-7ff78ddf7-rcfw2 -- wget -qO- http://localhost:8888/user-service/default
 -- 여기는 동작 한다. 

kubectl exec -it config-deployment-7ff78ddf7-rcfw2 -- wget -qO- http://config:8888/apigateway/default


kubectl exec -it apigateway-deployment-646cc5d587-r2qr5 -- wget -qO- http://config:8888/apigateway/default


kubectl run -it --rm --restart=Never busybox --image=busybox -- /bin/sh

cat /etc/resolv.conf


kubectl get endpoints config
kubectl get endpoints config


kubectl exec -it config-deployment-7ff78ddf7-rcfw2 -- netstat -tnlp | grep 8888
kubectl logs config-deployment-7ff78ddf7-rcfw2


네임스페이스 일치 여부
apigateway와 config 서비스가 같은 네임스페이스에 있어야
http://config:8888로 접근이 가능합니다.
다를 경우, <서비스이름>.<네임스페이스>.svc.cluster.local 형태로 접근해야 함
5. 네트워크 정책(NetworkPolicy) 및 방화벽
네트워크 정책이 적용되어 있다면,
apigateway 파드에서 config 서비스(8888포트)로의 트래픽이 허용되어야 함
6. 환경 변수/설정 파일 점검
apigateway의 환경 변수(bootstrap.yml, bootstrap.properties, SPRING_CLOUD_CONFIG_URI 등)에
config 서버 주소가 정확히 http://config:8888로 되어 있는지 확인
7. 기타 점검
config 서버가 너무 늦게 기동되거나, readinessProbe가 느려서
apigateway가 config 서버 기동 전 요청을 보내는 경우 (재시작으로 해결 가능)
config 서버 application.yml에 apigateway에 대한 설정이 실제로 존재하는지
요약 체크리스트
서비스 이름(config)과 네임스페이스 일치
서비스 엔드포인트(Endpoint) 연결 상태
config 파드 상태 및 8888 포트 리스닝 여부
네트워크 정책/방화벽
apigateway의 config 서버 주소 설정
config 서버 로그 및 application.yml 내 설정 존재 여부
위 항목을 차례대로 점검하면 대부분의 연결 문제를 빠르게 진단할 수 있습니다.
각 단계별로 결과나 로그를 공유해주시면, 구체적으로 원인 분석과 해결 방법을 안내해드릴 수 있습니다!

 

 kubectl exec -it apigateway-deployment-646cc5d587-r2qr5 -- nslookup config.default.svc.cluster.local
kubectl exec -it apigateway-deployment-646cc5d587-r2qr5 -- ping config.default.svc.cluster.local
kubectl exec -it -n kube-system coredns-79f77bf7cb-82tz7 -- sh
wget --spider --no-check-certificate  https://10.96.0.1:443


kubectl logs -n kube-system <coredns-pod-name> --tail=500

kubectl logs -n kube-system coredns-79f77bf7cb-gh74p --tail=500
kubectl logs -n kube-system coredns-79f77bf7cb-lcfd7 --tail=500


이럴 때 의심할 수 있는 핵심 원인
CoreDNS 파드가 kube-apiserver에 API 질의 자체를 못 하고 있음
인증 토큰(서비스어카운트) 마운트 문제
CoreDNS 파드의 환경변수/마운트/서비스어카운트 설정 문제
네트워크 플러그인(CNI) 문제로 API 트래픽이 차단
노드/파드의 시간(sync) 불일치로 인증 실패
Vagrant/가상환경에서 종종 발생

----
쿠버네티스 클러스터에서 CoreDNS 등 파드 간 통신, 서비스 디스커버리(DNS) 등이 동작하려면 반드시 네트워크 플러그인(CNI)이 설치되어 있어야 합니다.
CNI가 없으면 파드 간 네트워크가 불통이 되어, CoreDNS가 kube-apiserver와 통신하거나, 파드에서 DNS 질의가 동작하지 않습니다.
현재 이 문제가 발생하고 있으므로, CNI가 설치되지 않은 것이 DNS 실패의 근본 원인입니다.
----
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

kubectl get pods -n kube-system | grep flannel

kubectl exec -it config-deployment-7ff78ddf7-rcfw2 -- nslookup kubernetes.default.svc.cluster.local


kubectl delete -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml


curl -O https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml



bash
CopyInsert
kubectl get daemonset -n kube-flannel
kubectl get pods -n kube-flannel


e1:~$ kubectl exec -it $(kubectl get pods -n kube-system -l k8s-app=kube-dns -o name | head -1) -n kube-system -- nslookup kubernetes.default.svc.cluster.local 127.0.0.1
error: Internal error occurred: error executing command in container: failed to exec in container: failed to start exec "b30a70afd3d1ba7de0bd73fa32be9d3930eb033c084c76682d35774d2ac62fdb": OCI runtime exec failed: exec failed: unable to start container process: exec: "nslookup": executable file not found in $PATH: unknown
vagrant@control-plane1:~$ 

kubectl run -it --rm --restart=Never busybox --image=busybox:1.28 -- sh

nslookup kubernetes.default.svc.cluster.local
cat /etc/resolv.conf


kubectl get svc -n kube-system kube-dns
kubectl get endpoints -n kube-system kube-dns
kubectl get pods -n kube-system -l k8s-app=kube-proxy
kubectl logs -n kube-system -l k8s-app=kube-proxy --tail=100



네트워크 경로 및 iptables 문제 가능성
서비스/엔드포인트, kube-proxy 모두 정상인데 CoreDNS에 질의가 도달하지 않는다면,
노드의 iptables/netfilter, 혹은 CNI 설정 문제일 수 있습니다.
특히 Vagrant/가상환경에서는 bridge, NAT, 방화벽, iptables 정책이 꼬일 수 있습니다.
2. ClusterCIDR 설정 미확인
kube-proxy 로그에 "no cluster CIDR for family" 경고가 반복적으로 보입니다.
kubeadm으로 클러스터를 만들 때 --pod-network-cidr=10.244.0.0/16 옵션을 주었는지,
모든 노드의 kubelet/kube-proxy에 동일하게 적용되었는지 확인 필요.
3. 노드 iptables 정책 직접 확인
각 노드에서 다음 명령을 실행해보세요:

nt 0 Apr 21 08:29 1.txt
vagrant@worker1:/srv/nfs$ sudo iptables -t nat -L -n | grep 10.96.0.10
KUBE-SVC-TCOU7JCQXEZGVUNU  udp  --  0.0.0.0/0            10.96.0.10           /* kube-system/kube-dns:dns cluster IP */ udp dpt:53
KUBE-SVC-JD5MR3NA4I4DYORP  tcp  --  0.0.0.0/0            10.96.0.10           /* kube-system/kube-dns:metrics cluster IP */ tcp dpt:9153
KUBE-SVC-ERIFXISQEP7F7OF4  tcp  --  0.0.0.0/0            10.96.0.10           /* kube-system/kube-dns:dns-tcp cluster IP */ tcp dpt:53
KUBE-MARK-MASQ  tcp  -- !10.244.0.0/16        10.96.0.10           /* kube-system/kube-dn






kubectl get svc -n kube-system | grep kube-dns
kubectl get endpoints -n kube-system kube-dns
kubectl get pods -n kube-system | grep coredns
kubectl logs -n kube-system -l k8s-app=kube-dns
kubectl get pods -n kube-system


kubectl get pods -n kube-system | grep flannel
kubectl get pods -n kube-system | grep calico



kubectl run -it --rm --restart=Never busybox --image=busybox -- /bin/sh
nslookup updates.jenkins.io 10.96.0.10

kubectl -n kube-system get configmap coredns -o yaml


kubectl -n kube-system edit configmap coredns

forward . 8.8.8.8 1.1.1.1 {
   max_concurrent 1000
}

kubectl -n kube-system rollout restart deployment coredns


1. 서비스/엔드포인트 연결 확인

2. 파드 간 통신(flannel overlay 네트워크) 점검
3. kube-proxy 문제 가능성


nslookup updates.jenkins.io 10.96.0.10      # 서비스 IP로 질의
nslookup updates.jenkins.io 10.244.1.9     # CoreDNS 파드 Pod IP로 직접 질의
nslookup updates.jenkins.io 10.244.2.7


kubectl -n kube-system kube-dns


서비스 IP : 10.96.0.10    => 전체 ping이 안됀다. Pod안에서만ㄴ 통신되어야 함
ping 10.244.1.9   # worker1의 CoreDNS 파드 IP
ping 10.244.2.7   # worker2의 CoreDNS 파드 IP
ping 10.96.0.10

vagrant@control-plane1:~$ kubectl get svc -n kube-system kube-dns
NAME       TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)                  AGE
kube-dns   ClusterIP   10.96.0.10   <none>        53/UDP,53/TCP,9153/TCP   25h
vagrant@control-plane1:~$ kubectl get endpoints -n kube-system kube-dns
NAME       ENDPOINTS                                               AGE
kube-dns   10.244.1.9:53,10.244.2.7:53,10.244.1.9:53 + 3 more...   25h



ping 10.244.1.9 (worker1의 CoreDNS 파드 IP)는 worker1에서만 접속 가능,
worker2와 control-plane1에서는 접속 불가
ping 10.244.2.7 (worker2의 CoreDNS 파드 IP)는 worker2에서만 접속 가능,
worker1과 control-plane1에서는 접속 불가


즉, flannel(또는 다른 CNI)의 VXLAN 터널이 노드 간에 제대로 연결되지 않음




vagrant@control-plane1:~$ 
vagrant@control-plane1:~$ kubectl get pods -n kube-flannel
NAME                    READY   STATUS    RESTARTS   AGE
kube-flannel-ds-b62lt   1/1     Running   0          25h
kube-flannel-ds-dp52p   1/1     Running   0          25h
kube-flannel-ds-p2hlv   1/1     Running   0          25h


kubectl logs -n kube-flannel kube-flannel-ds-b62lt
kubectl logs -n kube-flannel kube-flannel-ds-dp52p
kubectl logs -n kube-flannel kube-flannel-ds-p2hlv

지금까지의 모든 결과(노드 간 Pod IP 통신 불가, 각 노드에서 자기 Pod만 ping 가능)는
flannel의 VXLAN 터널이 노드 간에 제대로 연결되지 않은 상태임을 명확히 보여줍니다.

sudo netstat -lunp | grep 8472


vagrant file 
config.vm.network "public_network", bridge: "en0: Wi-Fi (AirPort)"
# 또는
config.vm.network "private_network", type: "dhcp"




sudo ufw allow 8472/udp
sudo firewall-cmd --add-port=8472/udp --permanent
sudo firewall-cmd --reload


kubectl -n kube-flannel rollout restart daemonset kube-flannel-ds
kubectl -n kube-system rollout restart daemonset kube-proxy



노드 간 통신이 가능해야 하며, 일반적으로 flannel 
VXLAN(UDP 8472)도 이 네트워크를 통해 통신합니다.



 control-plane1에서
kubectl run test1 --image=busybox --restart=Never -- sleep 3600
kubectl run test2 --image=busybox --restart=Never -- sleep 3600

# Pod IP 확인
kubectl get pods -o wide

# Pod에 접속
kubectl exec -it test1 -- sh

# test2의 Pod IP로 ping
ping <test2의 Pod IP>



kubectl get svc -n kube-system | grep dns
kubectl get endpoints -n kube-system | grep dns
kubectl get pods -n kube-system -o wide | grep coredns


kubectl get serviceaccount -n kube-system
kubectl get clusterrolebinding | grep coredns
kubectl describe clusterrolebinding coredns


kube-apiserver의 서비스 토큰/인증서 문제
Kubernetes 1.24 이상에서 서비스 계정 토큰 자동 마운트 정책 변경 등