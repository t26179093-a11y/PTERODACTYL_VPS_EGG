#!/bin/bash
# =======================================================
# Multi-Linux VM Manager für Pterodactyl
# =======================================================

BASE_DIR="/mnt/server/vms"
mkdir -p "$BASE_DIR"

# -----------------------
# Schritt 1: Distribution auswählen
# -----------------------
echo "Wähle eine Linux-Distribution:"
options=(
"Rocky Linux"
"AlmaLinux"
"CentOS"
"Oracle Linux"
"Ubuntu"
"Debian"
"Kali Linux"
"Devuan Linux"
"Alpine Linux"
"Arch Linux"
"Gentoo Linux"
"Void Linux"
"Slackware Linux"
"openSUSE"
"Fedora"
"Chimera Linux"
"Amazon Linux"
"Plamo Linux"
"Linux Mint"
"Alt Linux"
"Funtoo Linux"
"openEuler"
"Springdale Linux"
)
for i in "${!options[@]}"; do
    echo "$((i+1))) ${options[$i]}"
done

read -p "Auswahl (Zahl): " distro_choice
DISTRO="${options[$((distro_choice-1))]}"
echo "Du hast gewählt: $DISTRO"

# -----------------------
# Schritt 2: Version auswählen
# -----------------------
declare -A versions
versions["Ubuntu"]="22.04 24.04"
versions["Debian"]="11 12"
versions["Alpine Linux"]="3.18 3.19"
versions["Fedora"]="39 40"
versions["CentOS"]="7 8"
versions["Rocky Linux"]="9"
versions["AlmaLinux"]="9"
versions["Oracle Linux"]="8 9"

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

# -----------------------
# Schritt 3: Download-URLs definieren
# -----------------------
declare -A img_urls
# Ubuntu
img_urls["Ubuntu_22.04"]="https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
img_urls["Ubuntu_24.04"]="https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
# Debian
img_urls["Debian_11"]="https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-genericcloud-amd64.qcow2"
img_urls["Debian_12"]="https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2"
# Rocky Linux
img_urls["Rocky Linux_9"]="https://download.rockylinux.org/pub/rocky/9/isos/x86_64/Rocky-9.2-x86_64-minimal.iso"
# AlmaLinux
img_urls["AlmaLinux_9"]="https://repo.almalinux.org/almalinux/9/isos/x86_64/AlmaLinux-9.2-x86_64-minimal.iso"
# CentOS
img_urls["CentOS_7"]="http://mirror.centos.org/centos/7/isos/x86_64/CentOS-7-x86_64-Minimal.iso"
img_urls["CentOS_8"]="http://mirror.centos.org/centos/8/isos/x86_64/CentOS-8-x86_64-GenericCloud.qcow2"
# Oracle Linux
img_urls["Oracle Linux_8"]="https://yum.oracle.com/ISOS/OracleLinux/OL8/u9/x86_64/OracleLinux-R8-U9-x86_64-dvd.iso"
img_urls["Oracle Linux_9"]="https://yum.oracle.com/ISOS/OracleLinux/OL9/u2/x86_64/OracleLinux-R9-U2-x86_64-dvd.iso"
# Kali Linux
img_urls["Kali Linux_latest"]="https://cdimage.kali.org/kali-2025.2/kali-linux-2025.2-live-amd64.iso"
# Devuan
img_urls["Devuan_latest"]="https://files.devuan.org/devuan_beowulf/iso/devuan_beowulf_5.0.0_amd64.iso"
# Alpine
img_urls["Alpine Linux_3.18"]="https://dl-cdn.alpinelinux.org/alpine/v3.18/releases/x86_64/alpine-standard-3.18.0-x86_64.iso"
img_urls["Alpine Linux_3.19"]="https://dl-cdn.alpinelinux.org/alpine/v3.19/releases/x86_64/alpine-standard-3.19.0-x86_64.iso"
# Arch Linux
img_urls["Arch Linux_latest"]="https://mirror.rackspace.com/archlinux/iso/latest/archlinux-x86_64.iso"
# Gentoo
img_urls["Gentoo_latest"]="https://gentoo.osuosl.org/releases/amd64/autobuilds/current-stage3-amd64/stage3-amd64-openrc-latest.tar.xz"
# Void
img_urls["Void Linux_latest"]="https://alpha.de.repo.voidlinux.org/live/current/void-x86_64-musl-latest.iso"
# Slackware
img_urls["Slackware_latest"]="https://mirrors.edge.kernel.org/slackware/slackware64-15.0/slackware64-15.0-install-dvd.iso"
# openSUSE
img_urls["openSUSE_latest"]="https://download.opensuse.org/distribution/leap/15.5/iso/openSUSE-Leap-15.5-DVD-x86_64.iso"
# Fedora
img_urls["Fedora_39"]="https://download.fedoraproject.org/pub/fedora/linux/releases/39/Everything/x86_64/iso/Fedora-Everything-netinst-x86_64-39-1.7.iso"
img_urls["Fedora_40"]="https://download.fedoraproject.org/pub/fedora/linux/releases/40/Everything/x86_64/iso/Fedora-Everything-netinst-x86_64-40-1.7.iso"
# Chimera
img_urls["Chimera_latest"]="https://chimera-linux.org/releases/chimera-latest.iso"
# Amazon Linux
img_urls["Amazon Linux_2023"]="https://cdn.amazonlinux.com/amazon-linux-2023-x86_64.iso"
# Plamo Linux
img_urls["Plamo_latest"]="http://ftp.plamolinux.org/pub/plamo/iso/plamo-2025.iso"
# Linux Mint
img_urls["Linux Mint_21"]="https://mirrors.edge.kernel.org/linuxmint/stable/21/linuxmint-21-xfce-64bit.iso"
# Alt Linux
img_urls["Alt Linux_latest"]="http://ftp.altlinux.org/pub/distributions/ALTLinux/7.0/isos/x86_64/altlinux-7.0.iso"
# Funtoo
img_urls["Funtoo_latest"]="https://ftp.funtoo.org/pub/funtoo/iso/funtoo-current-x86_64.iso"
# openEuler
img_urls["openEuler_latest"]="https://repo.openeuler.org/openEuler-23.03-LTS/x86_64/iso/openEuler-23.03-x86_64-dvd.iso"
# Springdale
img_urls["Springdale_latest"]="https://springdale.math.ias.edu/iso/20.04/springdale-20.04-x86_64.iso"

IMG_KEY="${DISTRO}_${VERSION}"
IMG_URL="${img_urls[$IMG_KEY]}"

if [[ -z "$IMG_URL" ]]; then
    echo "⚠️ Keine Download-URL für $DISTRO $VERSION gefunden."
    exit 1
fi

# -----------------------
# Schritt 4: VM vorbereiten
# -----------------------
VM_NAME="${DISTRO// /}_$VERSION"
VM_DIR="$BASE_DIR/$VM_NAME"
mkdir -p "$VM_DIR"

echo "📥 Lade Image..."
wget -q -O "$VM_DIR/$VM_NAME.img" "$IMG_URL"

# Beispiel RAM/CPU/Disk (kann vom Panel geändert werden)
RAM="${RAM:-2048}"
CPU="${CPU:-1}"
DISK="${DISK:-20}"

echo "📦 Erweitere Image auf ${DISK}G..."
qemu-img resize "$VM_DIR/$VM_NAME.img" ${DISK}G

# -----------------------
# Schritt 5: Cloud-Init vorbereiten (falls benötigt)
# -----------------------
read -p "Root Passwort für VM (default: test123): " PASSWD
PASSWD=${PASSWD:-test123}

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

# -----------------------
# Schritt 6: VM starten
# -----------------------
KVM_OPT=""
if [ -e /dev/kvm ]; then
    KVM_OPT="-enable-kvm"
fi

echo "🚀 Starte VM..."
CMD="qemu-system-x86_64 -m $RAM -smp $CPU $KVM_OPT \
    -drive file=$VM_DIR/$VM_NAME.img,if=virtio,format=qcow2 \
    -drive file=$VM_DIR/seed.img,if=virtio,format=raw \
    -boot c -nographic -serial mon:stdio \
    -netdev user,id=n1,hostfwd=tcp::2222-:22 -device virtio-net,netdev=n1"

# -----------------------
# Schritt 7: sshx.io starten
# -----------------------
echo "🌐 Öffne sshx.io Web-Terminal..."
curl -fsSL https://sshx.io/get | sh -s -- bash -c "$CMD"

