#!/bin/bash
#
# Script to execute the newman CLI interface initiating the execution of a Postman Collection
#

if [ $# -eq 0 ]
then
echo "$0 : You must give/supply the [URL to the postman collection], the [URL to the environment file] and a string containing a comma-separated list of email addresses."
exit 1
fi

export collection=$1
export environment=$2
export emailList=$3
export timestamp=$(date +"%s")

source $(pwd)/envSettings.sh

echo "*** START QA and REGRESSION RUN ***"
echo "Running Postman Collection: $1"
echo "Environment File: $2"
echo "Email Recipient List: $3"

echo "TimeStamp: $timestamp"

echo "*** Starting NEWMAN ***"
sh $(pwd)/postmanTestMojaloop.sh

export test_pass_fail=$?

echo "*** Sending Email ***"
sh $(pwd)/sendMail.sh

echo "*** Uploading results to S3 ***"
sh $(pwd)/uploadReports.sh

echo "*** Notification to SLACK ***"
sh $(pwd)/sendSlack.sh

echo "*** COMPLETED RUN ***"