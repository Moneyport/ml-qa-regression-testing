#!/usr/bin/env bash
#
# Script to execute default scripts
#

sh ./testMojaloop.sh "https://raw.githubusercontent.com/mojaloop/postman/master/Golden_Path.postman_collection.json" "https://raw.githubusercontent.com/mojaloop/postman/master/environments/Mojaloop-Local.postman_environment.json" "aaa@bbb.com, ddd@eee.com" 1 > runGolden_Path.log