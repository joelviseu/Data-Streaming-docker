#!/bin/bash
set -e
# Wait for MySQL to be ready
until nc -z -v -w30 mysql 3306
do
  echo "Waiting for MySQL database connection..."
  sleep 5
done
exec /opt/hive/bin/hive --service metastore