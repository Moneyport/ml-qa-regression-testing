#!/usr/bin/env bash

source $(pwd)/envSettings.sh

LOCAL_DIR=$(pwd)/environments

echo "aws s3 cp $LOCAL_DIR/$outfile $AWS_S3_BUCKET/$outfile"
cdir=$(pwd)
echo "curent dir=:$cdir"
aws s3 cp $LOCAL_DIR/$outfile $AWS_S3_BUCKET/$outfile
