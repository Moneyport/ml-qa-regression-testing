#!/usr/bin/env bash
#
# Script to execute default scripts
#

sh ./testMojaloop.sh "https://raw.githubusercontent.com/mojaloop/postman/master/Golden_Path.postman_collection.json" "https://raw.githubusercontent.com/mojaloop/postman/master/environments/Mojaloop-DEV0.postman_environment.json" "nico@modusbox.com,sam@modusbox.com,henk.kodde@modusbox.com,sridevi.miriyala@modusbox.com" 1 > runGolden_Path.log