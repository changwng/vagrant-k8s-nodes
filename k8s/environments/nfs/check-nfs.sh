#!/bin/bash

# --- 설정 부분 --- chmod +x check-nfs.sh ./check-nfs.sh 192.168.56.21 /srv/nfs
NFS_SERVER="${1:-192.168.56.21}"     # NFS 서버 주소 (인자 1로 받을 수 있음)
NFS_EXPORT_PATH="${2:-/srv/nfs}"    # NFS Export 경로 (인자 2로 받을 수 있음)
TEST_MOUNT_DIR="/srv/nfs/test"

# --- 유틸리티 체크 ---
echo "🔍 nfs-common 설치 여부 확인..."
if ! dpkg -s nfs-common &> /dev/null; then
    echo "❌ nfs-common이 설치되지 않았습니다. 설치를 진행하세요:"
    echo "    sudo apt update && sudo apt install -y nfs-common"
    exit 1
else
    echo "✅ nfs-common 설치 확인됨"
fi

# --- 네트워크 연결 확인 ---
echo "🔍 NFS 서버와 네트워크 연결 확인 중..."
ping -c 2 "$NFS_SERVER" &> /dev/null
if [ $? -ne 0 ]; then
    echo "❌ NFS 서버에 ping 실패 ($NFS_SERVER)"
    exit 1
else
    echo "✅ NFS 서버에 ping 성공"
fi

# --- NFS 포트 확인 (2049/tcp, 111/tcp) ---
echo "🔍 NFS 관련 포트 확인..."
for PORT in 2049 111; do
    if nc -z -v -w2 "$NFS_SERVER" "$PORT" &>/dev/null; then
        echo "✅ 포트 $PORT 열림"
    else
        echo "❌ 포트 $PORT 닫힘 — 방화벽 확인 필요"
    fi
done

# --- Export 목록 확인 ---
echo "🔍 Export 목록 확인 중..."
if showmount -e "$NFS_SERVER"; then
    echo "✅ Export 목록 확인 완료"
else
    echo "❌ showmount 실패 - NFS 서버에서 export가 공유되지 않았을 수 있음"
fi

# --- 마운트 테스트 ---
echo "🔍 NFS 마운트 테스트 중..."
mkdir -p "$TEST_MOUNT_DIR"
if mount -t nfs "$NFS_SERVER:$NFS_EXPORT_PATH" "$TEST_MOUNT_DIR" 2> /tmp/nfs_error.log; then
    echo "✅ NFS 마운트 성공"
    umount "$TEST_MOUNT_DIR"
else
    echo "❌ NFS 마운트 실패"
    cat /tmp/nfs_error.log
fi
rm -rf "$TEST_MOUNT_DIR"
rm -f /tmp/nfs_error.log

# --- 권한 확인 (read/write 테스트) ---
echo "🔍 권한 테스트 중..."
mkdir -p "$TEST_MOUNT_DIR"
mount -t nfs "$NFS_SERVER:$NFS_EXPORT_PATH" "$TEST_MOUNT_DIR" 2>/dev/null
if touch "$TEST_MOUNT_DIR/testfile" 2>/dev/null; then
    echo "✅ 쓰기 권한 있음"
    rm "$TEST_MOUNT_DIR/testfile"
else
    echo "❌ 쓰기 권한 없음 — no_root_squash 설정 여부 확인 필요"
fi
umount "$TEST_MOUNT_DIR"
rmdir "$TEST_MOUNT_DIR"

echo "✅ 모든 점검 완료!"