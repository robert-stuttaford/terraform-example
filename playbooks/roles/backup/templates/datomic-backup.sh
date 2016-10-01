#!/bin/bash -ex

export DATOMIC_LOG_DIR="/var/log/datomic-backup"
mkdir -p /var/log/datomic-backup

lockfile=/tmp/datomic_backup_s3.pid

if ( set -o noclobber; echo "locked" > "$lockfile") 2> /dev/null; then
  trap 'rm -f "$lockfile"; exit $?' INT TERM EXIT
  echo "$lockfile Locking succeeded"
  echo "Backing up to S3"
  /opt/datomic/bin/datomic backup-db \
    --encryption sse \
    -Ddatomic.s3BackupConcurrency=350 \
    "{{ database_backup_source_uri }}" \
    "{{ database_backup_target_uri }}"

  rm -f "$lockfile"
else
  echo "$lockfile Lock failed - exit"
  exit 1
fi
