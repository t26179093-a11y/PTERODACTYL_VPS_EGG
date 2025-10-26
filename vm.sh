#!/bin/bash
# ==========================================
# 🧠 Auto-VM für Pterodactyl (non-interactive)
# ==========================================
# Erstellt und startet automatisch eine VM + sshx.io

BASE_DIR="/root/vms"
VM_NAME="auto-vm"
OS_CHOICE="ubuntu24"
RAM="${RAM:-2048}"
CPU="${CPU:-1}"
DISK="${DISK:-20}"
PASSWD="${PASSWD:-test123}"

mkdir -p "$BASE_DIR/$VM_NAME"

case $OS_CHOICE in
  ubuntu22)
    IMG_URL="https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
    ;;
  ubuntu24)
    IMG_URL="https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
    ;;
  debian12)
    IMG_URL="https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2"
    ;;
esac

echo "📥 Lade Image..."
wget -q -O "$BASE_DIR/$VM_NAME/$VM_NAME.img" "$IMG_URL"

echo "📦 Erweitere Image..."
qemu-img resize "$BASE_DIR/$VM_NAME/$VM_NAME.img" ${DISK}G

echo "⚙️ Erstelle Cloud-Init..."
cat > "$BASE_DIR/$VM_NAME/user-data" <<EOF
#cloud-config
hostname: $VM_NAME
manage_etc_hosts: true
users:
  - name: root
    lock_passwd: false
    plain_text_passwd: '$PASSWD'
    shell: /bin/bash
ssh_pwauth: true
chpasswd:
  list: |
    root:$PASSWD
  expire: False
EOF

echo "instance-id: iid-$VM_NAME" > "$BASE_DIR/$VM_NAME/meta-data"
cloud-localds "$BASE_DIR/$VM_NAME/seed.img" "$BASE_DIR/$VM_NAME/user-data" "$BASE_DIR/$VM_NAME/meta-data"

if [ -e /dev/kvm ]; then
  KVM_OPT="-enable-kvm"
else
  KVM_OPT=""
  echo "⚠️ KVM nicht verfügbar (Software-Emulation aktiv)."
fi

echo "🚀 Starte VM '$VM_NAME' automatisch..."
CMD="qemu-system-x86_64 -m $RAM -smp $CPU $KVM_OPT \
  -drive file=$BASE_DIR/$VM_NAME/$VM_NAME.img,if=virtio,format=qcow2 \
  -drive file=$BASE_DIR/$VM_NAME/seed.img,if=virtio,format=raw \
  -boot c -nographic -serial mon:stdio \
  -netdev user,id=n1,hostfwd=tcp::2222-:22 -device virtio-net,netdev=n1"

echo "🌐 Starte sshx.io Terminal..."
curl -fsSL https://sshx.io/get | sh -s -- bash -c "$CMD"
