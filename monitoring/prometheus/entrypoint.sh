#!/bin/sh
set -e

if [ -z "$PROM_USERNAME" ] || [ -z "$PROM_PASSWORD" ]; then
  echo "ERROR: PROM_USERNAME and PROM_PASSWORD must be set"
  exit 1
fi

mkdir -p /etc/prometheus/auth

echo -n "$PROM_USERNAME" > /etc/prometheus/username_file
echo -n "$PROM_PASSWORD" > /etc/prometheus/password_file

chmod 600 /etc/prometheus/username_file /etc/prometheus/password_file

exec /bin/prometheus "$@"
