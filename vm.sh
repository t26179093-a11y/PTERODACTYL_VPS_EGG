#!/bin/bash
# ==========================================
# 🧠 VM Manager für Pterodactyl (Multi-Linux)
# ==========================================
BASE_DIR="/home/container/vms"
mkdir -p "$BASE_DIR"

# 1️⃣ Distribution auswählen
distros=("Ubuntu" "Debian" "Fedora" "CentOS" "Rocky Linux" "AlmaLinux" "Oracle Linux" "Kali Linux" "Devuan Linux" "Alpine Linux" "Arch Linux" "Gentoo Linux" "Void Linux" "Slackware Linux" "openSUSE" "Chimera Linux" "Amazon Linux" "Plamo Linux" "Linux Mint" "Alt Linux" "Funtoo Linux" "openEuler" "Springdale Linux")
echo "Wähle eine Linux-Distribution:"
for i in "${!distros[@]}"; do
    echo "$((i+1))) ${distros[$i]}"
done
read -p "Auswahl (Zahl): " distro_choice
DISTRO="${distros[$((distro_choice-1))]}"
echo "Du hast gewählt: $DISTRO"

# 2️⃣ Versionen definieren
declare -A versions
versions["Ubuntu"]="20.04 22.04 24.04"
versions["Debian"]="11 12"
versions["Fedora"]="39 40"
versions["CentOS"]="7 8 Stream 9"
versions["Rocky Linux"]="8 9"
versions["AlmaLinux"]="8 9"
versions["Oracle Linux"]="8 9"
versions["Alpine Linux"]="3.18 3.19"
versions["Arch Linux"]="latest"
versions["openSUSE"]="15.4 15.5"
versions["Kali Linux"]="latest"
# Die restlichen Distributionen nach Bedarf hinzufügen

if [[ -n "${versions[$DISTRO]}" ]]; then
    echo "Verfügbare Versionen für $DISTRO:"
    ver_list=(${versions[$DISTRO]})
    for i in "${!ver_list[@]}"; do
        echo "$((i+1))) ${ver_list[$i]}"
    done
    read -p "Version wählen (Zahl): " ver_choice
    VERSION="${ver_list[$((ver_choice-1))]}"
else
    VERSION="latest"
fi
echo "Version gewählt: $VERSION"

# 3️⃣ Image URLs
declare -A img_urls
# Ubuntu
img_urls["Ubuntu_20.04"]="https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img"
img_urls["Ubuntu_22.04"]="https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
img_urls["Ubuntu_24.04"]="https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
# Debian
img_urls["Debian_11"]="https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-genericcloud-amd64.qcow2"
img_urls["Debian_12"]="https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2"
# Fedora
img_urls["Fedora_39"]="https://download.fedoraproject.org/pub/fedora/linux/releases/39/Cloud/x86_64/images/Fedora-Cloud-Base-39-1.4.x86_64.qcow2"
img_urls["Fedora_40"]="https://download.fedoraproject.org/pub/fedora/linux/releases/40/Cloud/x86_64/images/Fedora-Cloud-Base-40-1.4.x86_64.qcow2"
# CentOS
img_urls["CentOS_7"]="https://download.centos.org/centos/7/images/CentOS-7-GenericCloud-7.9-20210701.2.x86_64.qcow2"
img_urls["CentOS_8"]="https://download.centos.org/centos/8-stream/x86_64/images/CentOS-Stream-8-GenericCloud-8.4-20210501.2.x86_64.qcow2"
img_urls["CentOS_Stream 9"]="https://download.centos.org/centos/9-stream/x86_64/images/CentOS-Stream-9-GenericCloud-9.0-20210701.2.x86_64.qcow2"
# Rocky Linux
img_urls["Rocky Linux_8"]="https://download.rockylinux.org/pub/rocky/8/images/Rocky-8-GenericCloud-8.4-20210701.2.x86_64.qcow2"
img_urls["Rocky Linux_9"]="https://download.rockylinux.org/pub/rocky/9/images/Rocky-9-GenericCloud-9.0-20210701.2.x86_64.qcow2"
# AlmaLinux
img_urls["AlmaLinux_8"]="https://repo.almalinux.org/almalinux/8/cloud/x86_64/images/AlmaLinux-8-GenericCloud-latest.x86_64.qcow2"
img_urls["AlmaLinux_9"]="https://repo.almalinux.org/almalinux/9/cloud/x86_64/images/AlmaLinux-9-GenericCloud-latest.x86_64.qcow2"
# Oracle Linux
img_urls["Oracle Linux_8"]="https://yum.oracle.com/repo/OracleLinux/OL8/latest/x86_64/iso/OracleLinux-R8-U8-x86_64-dvd.iso"
img_urls["Oracle Linux_9"]="https://yum.oracle.com/repo/OracleLinux/OL9/latest/x86_64/iso/OracleLinux-R9-U1-x86_64-dvd.iso"
# Alpine
img_urls["Alpine Linux_3.18"]="https://dl-cdn.alpinelinux.org/alpine/v3.18/releases/x86_64/alpine-standard-3.18.0-x86_64.iso"
img_urls["Alpine Linux_3.19"]="https://dl-cdn.alpinelinux.org/alpine/v3.19/releases/x86_64/alpine-standard-3.19.0-x86_64.iso"
# Arch
img_urls["Arch Linux_latest"]="https://archlinux.org/iso/latest/archlinux-x86_64.iso"
# openSUSE
img_urls["openSUSE_15.4"]="https://download.opensuse.org/distribution/leap/15.4/iso/openSUSE-Leap-15.4-DVD-x86_64.iso"
img_urls["openSUSE_15.5"]="https://download.opensuse.org/distribution/leap/15.5/iso/openSUSE-Leap-15.5-DVD-x86_64.iso"
# Kali Linux
img_urls["Kali Linux_latest"]="https://cdimage.kali.org/kali-2025.1/kali-linux-2025.1-live-amd64.iso"

IMG_KEY="${DISTRO}_${VERSION}"
IMG_URL="${img_urls[$IMG_KEY]}"

if [[ -z "$IMG_URL" ]]; then
    echo "⚠️ Keine URL für $DISTRO $VERSION gefunden."
    exit 1
fi

# 4️⃣ VM vorbereiten
VM_NAME="${DISTRO// /}_$VERSION"
VM_DIR="$BASE_DIR/$VM_NAME"
mkdir -p "$VM_DIR"

echo "📥 Lade Image..."
wget -q -O "$VM_DIR/$VM_NAME.img" "$IMG_URL"

read -p "RAM in MB (default 2048): " RAM
RAM=${RAM:-2048}
read -p "CPU-Kerne (default 1): " CPU
CPU=${CPU:-2}
read -p "Disk Größe in GB (default 20): " DISK
DISK=${DISK:-20}
read -p "Root-Passwort (default root): " PASSWD
PASSWD=${PASSWD:-root}

echo "📦 Erstelle Cloud-Init..."
cat > "$VM_DIR/user-data" <<EOF
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

echo "instance-id: iid-$VM_NAME" > "$VM_DIR/meta-data"
cloud-localds "$VM_DIR/seed.img" "$VM_DIR/user-data" "$VM_DIR/meta-data"

KVM_OPT=""
if [ -e /dev/kvm ]; then KVM_OPT="-enable-kvm"; fi

echo "🚀 Starte VM $VM_NAME..."
CMD="qemu-system-x86_64 -m $RAM -smp $CPU $KVM_OPT -drive file=$VM_DIR/$VM_NAME.img,if=virtio,format=qcow2 -drive file=$VM_DIR/seed.img,if=virtio,format=raw -boot c -nographic -serial mon:stdio -netdev user,id=n1,hostfwd=tcp::2222-:22 -device virtio-net,netdev=n1"

echo "🌐 Öffne sshx.io Web-Terminal..."
curl -fsSL https://sshx.io/get | sh -s -- bash -c "$CMD"
