#!/bin/bash
cd /mnt/server || exit 1
echo "🔹 Update + Pakete installieren..."
apt update -y || true
apt install -y qemu-system-x86 qemu-utils cloud-image-utils wget curl git || true
chmod +x vm.sh install.sh
echo "✅ Installation fertig! Starte vm.sh..."
bash vm.sh
