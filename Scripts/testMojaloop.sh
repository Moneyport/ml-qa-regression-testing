#!/bin/bash
#
# Script to execute the newman CLI interface initiating the execution of a Postman Collection
#

if [ $# -eq 0 ]
then
echo "$0 : You must give/supply the [URL to the postman collection] and a string containing a comma-separated list of email addresses."
exit 1
fi

export collection=$1
export emailList=$2
export timestamp=$(date +"%s")

source $(pwd)/envSettings.sh

echo "*** START QA and REGRESSION RUN ***"
echo "Running Postman Collection: $1"
echo "Email Recipient List: $2"

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