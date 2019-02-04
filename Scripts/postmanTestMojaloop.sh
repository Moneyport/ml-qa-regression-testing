#!/bin/bash
#
# Script to execute the newman CLI interface initiating the execution of a Postman Collection
#

if [ $# -eq 0 ]
then
echo "$0 : You must give/supply the [URL to the postman collection], [the number of times to run the test], [true] to exit at the first error or [false] to continue to the end and lastly, a string containing a semi-colon separated list of email addresses."
exit 1
fi

echo "Running Postman Collection: $1"
echo "Iterations: $2"
echo "Exit at first Error: $3"
echo "Email Recipient List: $4"

# Settings
timestamp=$(date +"%s")
collection=$1
emailList='$4'
env=/environments/Mojaloop-Sandbox.postman_environment.json
executionDateTime=`date +"%Y-%m-%d %T"`

# create separate outfile for each run
outfile=/var/www/myapp/tests/report-$timestamp.json

echo Executed at: ${executionDateTime}

get_mimetype()
{
  Xfname="$1"
  [ "$Xfname" = "" ] && echo "usage:$0 fname" >&2 && return 1
  [ ! -f "$Xfname" ] && echo "no file $Xfname" >&2 && return 2
  mtype=$(file --mime-type "$Xfname" )
  mtype=${mtype##* } # take last value from the answer, space is delim.
  echo "$mtype"
}

# Start Simulators
#sudo docker run -p 8444:8444 -t mojaloop/simulator:v1.0.6-snapshot

#cn=$(docker ps -al | awk '{print $1}')

if test $3 == true
then
	command=sudo docker run -v=/home/ec2-user/environments:/environments -t nicod/docker-newman:1 run $collection --folder "pm_happy_path" -e $env --delay-request 1000 --reporters cli,html --reporter-html-export /environments/report.html --reporter-html-template /environments/newmanReportTemplate.hbs -n $2 --bail
else
	command=sudo docker run -v=/home/ec2-user/environments:/environments -t nicod/docker-newman:1 run $collection --folder "pm_happy_path" -e $env --delay-request 1000 --reporters cli,html --reporter-html-export /environments/report.html --reporter-html-template /environments/newmanReportTemplate.hbs -n $2
fi

# If you want to send email based on a prepared file containing all parameters
#docker ps -al | grep -q 'Exited (0)' && /usr/sbin/sendmail -t < ./email/email-pass.txt
#docker ps -al | grep -q 'Exited (1)' && /usr/sbin/sendmail -t < ./email/email-fail.txt

# Stop Simulators
#sudo docker stop $cn

# Format subject line for email based on success/failure of test run
docker ps -al | grep -q 'Exited (0)' && subjectLine='QA-Regression Testing - PASSED'
docker ps -al | grep -q 'Exited (1)' && subjectLine='QA-Regression Testing - FAILED'

# Format email and distribute
from='awsoeasy.info'
to=$4
#subject=''
boundary="ZZ_/afg6432dfgkl.94531q"
body='Your test Report attached'
declare -a attachments
attachments=("./environments/report.html")

# Build headers
{

printf '%s\n' "From: $from
To: $to
Subject: $subjectLine
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=\"$boundary\"

--${boundary}
Content-Type: text/plain; charset=\"US-ASCII\"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

$body
"

# now loop over the attachments, guess the type
# and produce the corresponding part, encoded base64
for file in "${attachments[@]}"; do

  [ ! -f "$file" ] && echo "Warning: attachment $file not found, skipping" >&2 && continue

  mimetype=$(get_mimetype "$file")

  printf '%s\n' "--${boundary}
Content-Type: $mimetype
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename=\"$file\"
"

  base64 "$file"
  echo
done

# print last boundary with closing --
printf '%s\n' "--${boundary}--"

} | /usr/sbin/sendmail -t -oi   # one may also use -f here to set the envelope-from

