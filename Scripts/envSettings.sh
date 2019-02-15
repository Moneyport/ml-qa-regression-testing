#!/usr/bin/env bash

export SLACK_WEBHOOK_ANNOUNCEMENT=<URL to Webhook Announcement>
export MOJALOOP_OSS_RESULT_URL=<Mojaloop Report URL>

export AWS_ACCESS_KEY_ID=<AWS Access Key>
export AWS_SECRET_ACCESS_KEY=<AWS Secret Access Key>
export AWS_S3_BUCKET=<S3 Bucket URL>

export env=<Postman Environment JSON File>
export executionDateTime=`date +"%Y-%m-%d %T"`
export outfile="report-$timestamp.html"
