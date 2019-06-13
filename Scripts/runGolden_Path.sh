#!/usr/bin/env bash
#
# Script to execute default scripts
#

sh ./testMojaloop.sh "https://raw.githubusercontent.com/mojaloop/postman/master/Golden_Path.postman_collection.json" "https://raw.githubusercontent.com/mojaloop/deploy-config/deploy/PI6.4/postmanEnvironments/Mojaloop-DEV0.postman_environment.json?token=ACG3PR3Z36U23XIF3YV2X225BNWKG" "nico@modusbox.com,sam@modusbox.com,henk.kodde@modusbox.com,sridevi.miriyala@modusbox.com" 1 > runGolden_Path.log