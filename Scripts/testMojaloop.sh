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

source envSettings.sh

echo "Running Postman Collection: $1"
echo "Email Recipient List: $2"

sh ./postmanTestMojaloop.sh

export test_pass_fail=$?

sh ./sendMail.sh
sh ./uploadReports.sh
sh ./sendSlack.sh