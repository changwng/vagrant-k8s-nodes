# Vagrant와 Kubernetes 배포 환경 분석 보고서

## 1. 개요

이 보고서는 `/Users/changwng/workspace.edu/ms_edu_kube/k8s` 디렉토리에 구성된 Vagrant를 사용한 Kubernetes 설치 및 배포 환경에 대한 분석을 제공합니다. 이 환경은 Vagrant를 통해 가상 머신을 생성하고, 그 위에 Kubernetes 클러스터를 구축한 후, 다양한 서비스를 배포하는 과정을 자동화하고 있습니다.

## 2. 환경 구성

### 2.1 가상 머신 구성 (Vagrantfile)

- **기반 이미지**: Ubuntu 20.04 (generic/ubuntu2004)
- **가상화 제공자**: QEMU
- **노드 구성**:
  - **Control Plane**: 1개 노드 (IP: 192.168.56.21)
  - **Worker 노드**: 2개 노드 (IP: 192.168.56.22, 192.168.56.23)
- **리소스 할당**:
  - 메모리: 4GB
  - CPU: 2코어
- **포트 포워딩**:
  - Control Plane: 2421 -> 22
  - Worker1: 2422 -> 22
  - Worker2: 2423 -> 22

### 2.2 Kubernetes 설치 과정

Vagrantfile에 정의된 스크립트를 통해 각 노드에 다음과 같은 설치 과정이 자동화되어 있습니다:

1. 시스템 설정 최적화 (스왑 비활성화, 네트워크 설정 등)
2. Docker 설치 및 구성 (systemd cgroup driver 사용)
3. Kubernetes 패키지 설치 (kubelet, kubeadm, kubectl)
4. Control Plane 초기화 (kubeadm init)
5. Worker 노드 조인 (join-command.sh 생성 및 실행)
6. Flannel CNI 플러그인 설치 (네트워크 CIDR: 10.244.0.0/16)

## 3. 서비스 배포 구조

### 3.1 환경 구성 요소 (environments)

다음과 같은 환경 구성 요소들이 준비되어 있습니다:

- **configmaps**: 애플리케이션 설정을 위한 ConfigMap 리소스
- **databases**: 데이터베이스 서비스 (MySQL, PostgreSQL 등)
- **jenkins**: CI/CD 파이프라인을 위한 Jenkins 서비스
- **logging**: 로깅 시스템 (ELK 스택 등)
- **nfs**: 네트워크 파일 시스템 설정
- **rabbitmq**: 메시지 큐 서비스
- **zipkin**: 분산 추적 시스템

### 3.2 애플리케이션 구성 요소 (applications)

애플리케이션은 다음과 같이 구성되어 있습니다:

- **backend**: 백엔드 서비스 컴포넌트
- **frontend**: 프론트엔드 서비스 컴포넌트

### 3.3 스토리지 옵션 (storage)

두 가지 스토리지 옵션이 제공됩니다:

- **NFS**: 네트워크 파일 시스템을 통한 스토리지 제공
  - ReadWriteMany 접근 모드 지원
  - 5Gi 스토리지 용량 요청
- **OpenStack**: PaaS-TA 환경에서 Cinder 볼륨을 통한 스토리지 제공

## 4. 배포 프로세스

### 4.1 배포 순서

1. **Ingress Controller 배포**:
   ```
   kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.4/deploy/static/provider/baremetal/deploy.yaml
   ```

2. **환경 배포**:
   ```
   kubectl apply -k k8s/environments
   ```

3. **스토리지 배포** (NFS 또는 OpenStack):
   ```
   kubectl apply -k k8s/storage/nfs
   ```
   또는
   ```
   kubectl apply -k k8s/storage/openstack
   ```

4. **애플리케이션 배포**:
   ```
   kubectl apply -k k8s/applications
   ```

### 4.2 서비스 종료 프로세스

배포 순서의 역순으로 진행:

1. **애플리케이션 종료**
2. **환경 종료**
3. **스토리지 종료**

## 5. 주요 특징 및 장점

1. **자동화된 환경 구축**: Vagrant를 통해 가상 머신 생성부터 Kubernetes 설치까지 자동화
2. **다양한 환경 지원**: 개발, 테스트, 프로덕션 등 다양한 환경 구성 가능
3. **모듈화된 구조**: 환경, 애플리케이션, 스토리지가 명확히 분리되어 유지보수 용이
4. **스토리지 옵션**: NFS 및 OpenStack Cinder 등 다양한 스토리지 옵션 제공
5. **Kustomize 활용**: Kubernetes 리소스 관리를 위한 Kustomize 도구 활용

## 6. 사용 방법

1. **환경 구축**:
   ```
   vagrant up
   ```

2. **서비스 배포**:
   - Ingress Controller 배포
   - 환경 배포
   - 스토리지 배포
   - 애플리케이션 배포

3. **서비스 접근**:
   - 노드 IP 확인: `kubectl get nodes -o wide`
   - 서비스 확인: `kubectl get svc -A`

## 7. 결론

이 환경은 Vagrant와 Kubernetes를 활용하여 마이크로서비스 아키텍처 기반의 애플리케이션을 쉽게 배포하고 관리할 수 있는 구조를 제공합니다. 개발자는 로컬 환경에서 Kubernetes 클러스터를 구축하고, 다양한 서비스 컴포넌트를 배포하여 실제 프로덕션 환경과 유사한 조건에서 개발 및 테스트를 진행할 수 있습니다.

특히 NFS와 OpenStack Cinder와 같은 다양한 스토리지 옵션을 제공하여 환경에 따라 적절한 스토리지 솔루션을 선택할 수 있는 유연성을 제공합니다. 또한 Kustomize를 활용하여 Kubernetes 리소스를 효율적으로 관리할 수 있는 구조를 갖추고 있습니다.
