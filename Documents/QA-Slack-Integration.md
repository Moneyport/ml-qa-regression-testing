# Mojaloop - Test Report integration with Slack

We use Postman to test all aspects of the mojaloop system. In order to automate this process specifically for the Schedulted Daily test cycle, we utilise Newman, which is a Node Package which interacts directly with Postman in the background and in turn, exposes testing interaction via a command line interface (CLI).

#Parameter Requirements
The entire process can then be driven by bash scripts and when triggered (manually or scheduled by a cron-job) creates a Docker container from a predefined image (please see <DockerFile>). The environment is then prepared for the run by taking the required input parameters:
 1) Postman Collection to execute
 1) Environment file to use which specifies the specific Mojaloop Implementation to execute against
 1) Comma-seperated list of email recipients to receive the generated testing report
 1) Notification flag (0 or 1) which indicates the request to distribute any results (Slack or Email) or do a silent run (For testing the QA-Regression Test process itself)

The only input required from anyone wishing to execute a test, will be the parameters defined above. The entire process is fully automated and integrated.

#QA Automation Process
When the Notification flag parameter is on (1), the process starts by:
 1) preparing the runtime environment, 
 1) spinning up a Docker Container,
 1) executing the Newman instructions,
 1) saving the required report,
 1) copying the report to an S3 bucket on AWS,
 1) sending out an email, attaching the report,
 1) interfacing with Slack by uploading the report to a predefined Slack Channel and indicating the success or failure as well as the input parameters used for the run.
 
#Slack Notification Integration
In order to get the Slack integration to work, one must do the following:
 1) first create a dedicated Slack Channel,
 1) Create a Slack app (if you don't already have one) - SlackBot
 1) Enable Incoming Webhooks from the settings page.
 1) After the settings page refreshes, click Add New Webhook to Workspace.
 1) Pick the channel identified as receiving the notification, then click Authorize.
 1) Use your Incoming Webhook URL to post a message to Slack.
 
Below is the bash script we use to automate the sending of the generated test report to the dedicated slack channel. Please note that the SLACK_WEBHOOK_ANNOUNCEMENT value is an environment variable we defined. Your value would obviously be specific to your Slack Channel.

#Integration Code
/#!/usr/bin/env bash

source $(pwd)/envSettings.sh

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
  \"text\": \"*QA-Regression Report* for $collection on $environment at *$executionDateTime* - \`$testResult\`\",
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
