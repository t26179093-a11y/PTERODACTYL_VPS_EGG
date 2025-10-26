#!/bin/bash
# ==========================================
# Installation für Auto-VM Egg
# ==========================================

cd /mnt/server || exit 1

echo "Installing dependencies..."
apt update -y
apt install -y qemu-system-x86 qemu-utils cloud-image-utils wget curl || true

chmod +x /mnt/server/vm.sh
echo "✅ Installation abgeschlossen! Starte die VM mit ./vm.sh"
