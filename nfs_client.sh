echo '********** 4) NFS 클라이언트 설정 **********'
sudo apt install -y nfs-common
sudo mkdir -p /srv/nfs/k8s
echo "192.168.56.40:/srv/nfs/k8s /srv/nfs/k8s nfs defaults 0 0" | sudo tee -a /etc/fstab
sudo mount -a
mount | grep nfs