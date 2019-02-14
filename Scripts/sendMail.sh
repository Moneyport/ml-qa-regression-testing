#!/usr/bin/env bash

# some variables
# refactoring the script such that all these values are
# passed from the outside as arguments should be easy

source envSettings.sh

# Format email and distribute
from='awsoeasy.info'
to=$emailList
#subjectLine=''
boundary="ZZ_/afg6432dfgkl.94531q"
body='The attached file contains the results of this QA-Regression Run'
declare -a attachments
attachments=("./environments/$outfile")

echo outfile=$outfile
echo emailList=$emailList

get_mimetype()
{
  Xfname="$1"
  [ "$Xfname" = "" ] && echo "usage:$0 fname" >&2 && return 1
  [ ! -f "$Xfname" ] && echo "no file $Xfname" >&2 && return 2
  mtype=$(file --mime-type "$Xfname" )
  mtype=${mtype##* } # take last value from the answer, space is delim.
  echo "$mtype"
}

if [ $test_pass_fail -eq 0 ]
then
    subjectLine='QA-Regression Testing - PASSED'
else
    subjectLine='QA-Regression Testing - FAILED'
fi

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
