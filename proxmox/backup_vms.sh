#!/bin/bash
#===============================================================================
# Script:        backup_vms.sh
# Description:   Резервное копирование указанных (или всех) VM в Proxmox.
#                Использует vzdump с ZSTD, хранит архивы локально.
# Author:        R2BNY
# Created:       2025-05-10
# Version:       1.0.0
# Environment:   Proxmox VE, Bash
#===============================================================================
BACKUP_DIR="/data/dump"
VM_IDS=("101" "102" "105")  # Укажи ID нужных ВМ. Если VM_IDS=() оставить пустым, сделает бэкап всех.

# Создание каталога если нет
mkdir -p "$BACKUP_DIR"

echo "[*] Начинаем резервное копирование в $BACKUP_DIR"
DATE=$(date +"%Y-%m-%d_%H-%M")

if [[ ${#VM_IDS[@]} -eq 0 ]]; then
    echo "Виртуальные машины не указаны, выполняем резервное копирование всех виртуальных машин"
    vzdump --compress zstd --mode snapshot --storage local --dumpdir "$BACKUP_DIR" --quiet 1
else
    for VMID in "${VM_IDS[@]}"; do
        echo "Резервное копирование виртуальной машины: $VMID"
        vzdump "$VMID" --compress zstd --mode snapshot --storage local --dumpdir "$BACKUP_DIR" --quiet 1
    done
fi

echo "Резервное копирование завершено: $DATE"
#===============================================================================
# End of script — R2BNY
# $(date +"%F %T") — exit code: $?
#===============================================================================
