NodeCnt = 1

Vagrant.configure("2") do |config|

  config.vm.box = "bento/ubuntu-22.04"
  config.vm.synced_folder "./", "/vagrant", disabled: true
  config.vm.provision :shell, privileged: true, inline: $install_common_tools

  config.vm.define "k8s-master" do |master|
    master.vm.hostname = "k8s-master"
    master.vm.network "private_network", ip: "192.168.56.30"
    master.vm.provider :vmware_fusion do |vf|
      vf.memory = 4096
      vf.cpus = 4
    end
    master.vm.provision :shell, privileged: true, inline: $provision_master_node
  end

  (1..NodeCnt).each do |i|
    config.vm.define "k8s-node#{i}" do |node|
      node.vm.hostname = "k8s-node#{i}"
      node.vm.network "private_network", ip: "192.168.56.#{i + 30}"
      node.vm.provider :vmware_fusion do |vf|
        vf.memory = 2048
        vf.cpus = 2
      end
    end
  end
end

$install_common_tools = <<-SHELL

echo '********** 1) 타임존 셋팅 **********'
timedatectl set-timezone Asia/Seoul

echo '********** 2) Hosts 수정 **********'
cat << EOF >> /etc/hosts
192.168.56.30 k8s-master
192.168.56.31 k8s-node1
EOF

echo '********** 3) 방화벽 해제 및 Swap 비활성화 및 필수 커널 모듈 로드 및 sysctl 설정 **********'
systemctl stop ufw && systemctl disable ufw
swapoff -a && sed -i '/ swap / s/^/#/' /etc/fstab
modprobe overlay && modprobe br_netfilter
cat << EOF >> /etc/sysctl.d/kubernetes.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sysctl --system

echo '********** 4) Containerd (컨테이너 런타임) 다운로드 **********'
apt update -y
apt install -y containerd
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
systemctl restart containerd && systemctl enable --now containerd

echo '********** 5) Kubernetes 패키지 다운로드 **********'
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | \
  sudo tee /etc/apt/keyrings/kubernetes-apt-keyring.asc > /dev/null

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.asc] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | \ 
  sudo tee /etc/apt/sources.list.d/kubernetes.list

apt update -y
apt install -y kubelet=1.32.1-1.1 kubeadm=1.32.1-1.1 kubectl=1.32.1-1.1
apt-mark hold kubelet kubeadm kubectl

SHELL

$provision_master_node = <<-SHELL

echo '********** 1) kubeadm으로 클러스터 생성  **********'
kubeadm init --pod-network-cidr=20.96.0.0/16 --apiserver-advertise-address 192.168.56.30

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

echo '********** 2) Calico 네트워크 플러그인 설치 **********'
kubectl apply -f https://docs.projectcalico.org/v3.25/manifests/calico.yaml

echo '********** 3) kubeadm 토큰 생성 및 조인 명령 저장 **********'
kubeadm token create --print-join-command > /home/vagrant/join.sh

echo '********** 4) Kubernetes 대시보드 및 Metrics Server 설치 **********'
kubectl apply -f https://raw.githubusercontent.com/k8s-1pro/install/main/ground/k8s-1.27/dashboard-2.7.0/dashboard.yaml
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

kubectl taint nodes k8s-master node-role.kubernetes.io/control-plane:NoSchedule-

kubectl patch deployment metrics-server -n kube-system --type='json' \
  -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls"}]'

kubectl patch deployment kubernetes-dashboard -n kubernetes-dashboard \
  --type='json' \
  -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--enable-skip-login"}]'

sleep 180 && nohup kubectl port-forward -n kubernetes-dashboard svc/kubernetes-dashboard 8443:443 --address 0.0.0.0 > /dev/null 2>&1 &

SHELL
