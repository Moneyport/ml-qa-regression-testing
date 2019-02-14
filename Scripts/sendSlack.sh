#!/usr/bin/env bash

source envSettings.sh

if [ $test_pass_fail -eq 0 ]
then
    testResult='PASSED'
else
    testResult='FAILED'
fi

curl -X POST \
  $SLACK_WEBHOOK_ANNOUNCEMENT \
  -H 'Content-type: application/json' \
  -H 'cache-control: no-cache' \
  -d "{
  \"text\": \"*QA Framework test results* for *$executionDateTime* - \`$testResult\`\",
  \"attachments\": [
    {
      \"fallback\": \"View QA and Regression test results @ $MOJALOOP_OSS_RESULT_URL/$outfile\",
      \"actions\": [
        {
          \"type\": \"button\",
          \"text\": \"View QA and Regression test results\",
          \"url\": \"$MOJALOOP_OSS_RESULT_URL/$outfile\"
        }
      ]
    }
  ]
}"