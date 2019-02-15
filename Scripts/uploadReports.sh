#!/usr/bin/env bash

source envSettings.sh

LOCAL_DIR=./environments

aws s3 cp $LOCAL_DIR/$outfile $AWS_S3_BUCKET/$outfile