#!/bin/bash
#
# Script to execute the newman CLI interface initiating the execution of a Postman Collection
#

source $(pwd)/envSettings.sh

DOCKER_NETWORK='QA_NETWORK'
SIM_HOST='QA_SIMULATOR'
SIM_IMAGE='mojaloop/simulator'
SIM_TAG='v1.0.6-snapshot'
NEWMAN_HOST='QA_NEWMAN'
NEWMAN_IMAGE='nicod/docker-newman'
NEWMAN_TAG='2'

echo "*** postmanTestMojaloop START ***"

echo Executed at: ${executionDateTime}

create_network()
{
    echo "*** create_network $DOCKER_NETWORK START ***"
    docker network create $DOCKER_NETWORK
    echo "*** create_network $DOCKER_NETWORK END ***"
}

run_test_simulator() {
 echo "Running $SIM_HOST"
 docker run -id --rm \
   --network $DOCKER_NETWORK \
   --name $SIM_HOST \
   -p 8444:8444 \
   $SIM_IMAGE:$SIM_TAG
}

run_test_newman() {
 echo "Running $NEWMAN_HOST"
 docker run -i --rm \
   --link $SIM_HOST \
   --network $DOCKER_NETWORK \
   --name $NEWMAN_HOST \
   --env collection=$collection \
   --env environment=$environment \
   --env outfile=$outfile \
   -v=$(pwd)/environments:/environments \
   $NEWMAN_IMAGE:$NEWMAN_TAG \
   /bin/sh \
   -c "newman run $collection -e $environment --delay-request 1000 --reporters cli,html --reporter-html-export /environments/$outfile --reporter-html-template /environments/newmanReportTemplate.hbs"
}

stop_docker() {
  #echo "$SIM_HOST is shutting down"
  #(docker stop $SIM_HOST && docker rm $SIM_HOST) > /dev/null 2>&1
  echo "$NEWMAN_HOST environment is shutting down"
  (docker stop $NEWMAN_HOST && docker rm $NEWMAN_HOST) > /dev/null 2>&1
  echo "Deleting test network: $DOCKER_NETWORK"
  docker network rm $DOCKER_NETWORK
}

clean_docker() {
  stop_docker
}

clean_docker

create_network
#run_test_simulator
run_test_newman

test_exit_code=$?

clean_docker

echo "*** postmanTestMojaloop END with result = $test_exit_code ***"

exit $test_exit_code

