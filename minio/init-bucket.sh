#!/bin/bash
set -e
mc alias set myminio http://minio:9000 minio minio123
mc mb -p myminio/warehouse
mc policy set public myminio/warehouse