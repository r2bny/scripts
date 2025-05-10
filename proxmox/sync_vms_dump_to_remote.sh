#!/bin/bash
#===============================================================================
# Script:        sync_vms_dump_to_remote.sh
# Description:   Синхронизирует последние дампы виртуальных машин (.zst, .notes)
#                с локального хранилища на удалённый сервер по SSH (rsync).
# Author:        R2BNY
# Created:       2025-05-10
# Version:       1.0.0
# Environment:   Bash, rsync, ssh
#===============================================================================
SOURCE_DIR="/data/dump"
DEST_USER="user"
DEST_HOST="backups.r2bny.com"
DEST_PATH="/nfs/backups/company"
TARGET_VM_IDS=("100" "101" "102" "103" "104" "105")
# Чтобы синхронизировать все доступные дампы виртуальных машин, можно использовать следующую строку вместо перечисления вручную:
# TARGET_VM_IDS=($(ls "$SOURCE_DIR" | grep -oP '(?<=vzdump-qemu-)\d+(?=.*\.zst)' | sort -u))

echo "▶️ Запуск синхронизации с удалённым каталогом $DEST_PATH."
ssh "$DEST_USER@$DEST_HOST" "rm -f $DEST_PATH/*"
echo "✅ Очистка удалённого каталога $DEST_PATH завершена."

for VM_ID in "${TARGET_VM_IDS[@]}"; do
    VM_PREFIX="vzdump-qemu-${VM_ID}"

    # Найти последний .zst
    LATEST_ZST=$(ls -t "$SOURCE_DIR" | grep "^${VM_PREFIX}" | grep -E '\.zst$' | head -n 1)

    if [[ -n "$LATEST_ZST" ]]; then
        LATEST_BASE="${LATEST_ZST%.zst}"
        echo "Синхронизация дамп-файла $LATEST_ZST виртуальной машины с идентификатором $VM_ID в удалённый каталог."
        rsync -avz "$SOURCE_DIR/$LATEST_ZST" "$DEST_USER@$DEST_HOST:$DEST_PATH/" 2>/dev/null

        # Найти соответствующий .notes
        LATEST_NOTES=$(ls -t "$SOURCE_DIR" | grep "^${LATEST_BASE}" | grep -E '\.notes$' | head -n 1)
        if [[ -n "$LATEST_NOTES" ]]; then
            echo "Синхронизация заметок $LATEST_NOTES виртуальной машины с идентификатором $VM_ID в удалённый каталог."
            rsync -avz "$SOURCE_DIR/$LATEST_NOTES" "$DEST_USER@$DEST_HOST:$DEST_PATH/" 2>/dev/null
        fi
    else
        echo "Дамп-файл виртуальной машины с идентификатором [$VM_ID] не найден, приступаем к синхронизации следующей виртуальной машины."
    fi
done

echo "✅ Синхронизация завершена: $DATE"
#===============================================================================
# End of script
#===============================================================================