#!/bin/bash
cd /mnt/server || exit 1

echo "🔹 Update und Installation der Abhängigkeiten..."
apt update -y
apt install sudo bash git procps neofetch -y
apt install -y git curl wget qemu-system-x86 qemu-utils cloud-image-utils procps || true

chmod +x vm.sh install.sh

echo "✅ Installation abgeschlossen!"
echo "🚀 Starte vm.sh..."
bash vm.sh
