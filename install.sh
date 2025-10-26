#!/bin/bash
# ==========================================
# 🛠️ Installation für Auto-VM Egg
# ==========================================

apt update -y
apt install -y qemu-system-x86 qemu-utils cloud-image-utils wget curl

chmod +x /mnt/server/vm.sh

echo "✅ Installation abgeschlossen!"
echo "VM kann automatisch mit ./vm.sh gestartet werden."
