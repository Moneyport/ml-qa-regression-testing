#!/bin/bash
#
# Script to execute default scripts
#

sh ./testMojaloop.sh "https://raw.githubusercontent.com/mojaloop/postman/master/OSS-Feature-Tests.postman_collection.json" "https://raw.githubusercontent.com/mojaloop/ml-qa-cron/master/Documents/Mojaloop-DEV0.postman_environment.json?token=AI23x2Ns9u0Qnuzyxj43pwbQdAFmXK-Jks5cm5TgwA%3D%3D" "nico@modusbox.com,sam@modusbox.com,henk.kodde@modusbox.com,sridevi.miriyala@modusbox.com" 1 > runOSS-Feature-Tests.log
