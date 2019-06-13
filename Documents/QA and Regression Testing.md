# QA and Regression Testing in Mojaloop
An overview of the testing framework set up in Mojaloop

## Regression requirements
In order for a deployed system to be robust, one of the last checkpoints is to determine if the environment it is deployed in, is in a healthy state and all exposed functionality works exactly the way as intended. 
 
Contents:
1. [Environment information](#environment-information)
2. [Access and setup](#access-and-setup)
3. [Executing regression test](#executing-regression-test)
4. [Postman regression test with Newman](#postman-regression-test-with-newman)
5. [Automation and scheduling](#automation-and-scheduling)
6. [Known issues](#known-issues)

## Environment information
 General information on the EC2 testing environment

##### EC2 instance
 Create an EC2 instance with Node and Docker. Also install a Mail Server as set out in this document. Create a scheduled CronTab as defined in this document as well.

##### Name (distro) and version
 Determine name (distro) and version by executing
 cat /etc/*-release

##### Kernel Version
 Determine kernel version by executing 
 uname -a

## Access and setup
The [Approach](Approach.md) will provide guidelines to create and access the EC2 testing environment, how to set up and all the configurations required.

### EC2 structure of the Mojaloop testing environment
##### Files to copy to the EC2 instance (These were the filenames we used)
```
testMojaloop.sh
envSettings.sh
postmanTestMojaloop.sh
sendMail.sh
uploadReports.sh
sendSlack.sh
/environments/newmanReportTemplate.hbs
/Docker/Dockerfile
``` 
##### Docker file
```
scp -i <pemfilename.pem> "/Users/<UserID>/<Dockerfile>" ec2-user@<ec2-instance>:~
```
##### Newman HTML report template file
```
scp -i <pemfilename.pem> "/Users/<UserID>/<reportTemplateFile.hbs>" ec2-user@<ec2-instance>:~
```
##### Copy bash scripts to EC2
```
scp -i <pemfilename.pem> /Users/<UserID>/*.sh ec2-user@<ec2-instance>:~
```
##### Start the Docker Service
```
[ec2-user ~]$ sudo service docker start
```
Note - If the server was stopped and restarted, the Docker daemon will not be running. 
##### Add the ec2-user to the docker group so you can execute Docker commands without using sudo.
```
[ec2-user ~]$ sudo usermod -a -G docker ec2-user
```
##### You can name the image anything you like. Just remember to ensure the name of the image you use is updated in the script where it is referenced. Build Image from Dockerfile - Use docker file to obtain the latest required images an build a new image (using your own versioning system) with the following:
```
docker build -t <UserID>/docker-newman:1 .
```
##### Add userID to the docker list
 This will prevent having to type "sudo" to execute against it
```
sudo usermod -a -G docker ec2-user
```

## Executing regression test
Postman regression test can be executed by either instantiating a docker container or running a script(s).
##### Instantiating a Docker container on your LOCAL machine - ensure your image was created with the "default run command"
 Creation of an image containing all the required installations - via Newman CLI
 This procedure will create a Docker Container on your local machine with all the required internal processes required in order to run a Postman (CLI) test with Newman. You would need to "exec -it" into the container to run the required Newman command from a terminal. 
```
sudo docker run -v=/home/ec2-user/<local-location>:/<remote-location> -t postman/<docker-image-name> run <postman-collection-URL> -e /environments/environment-name.json -n 1 --bail
```
##### Execute the bash script to run the newman / postman test
To run a test via this method, you will have to be in posession of the PEM-file of the server on which the Mojaloop QA and Regression Framework was deployed on an EC2 instance on Amazon Cloud. 

SSH into the specific EC2 instance and when running the script, it will in turn run the commands via an instantiated Docker container.

You will notice that by using this approach where both the URLs for the Postman-Collection and Environment File are required as input parameters (together with a comma-delimited email recipient list for the report) you have total freedom of executing any Postman Collection you choose.
 
Also, by having an Environment File, the specific Mojaloop services targeted can be on any server. This means you can execute any Postman test against any Mojaloop installation on any server of your choice.
 
The EC2 instance we execute these tests from are merely containing all the tools and processes in order to execute your required test and does not host any Mojaloop Services as such.
```
./testMojaloop.sh <postman-collection-URL> <environment-URL> <comma-separated-email-recipient-list>
```
##### Verifying regression test results
Test for exit code result with grep in a bash script - test for exit code (1) indicating failure and execute a command (like sending out email)
```
docker ps -al | grep -q 'Exited (0)' && echo "success"
```

## Postman regression test with Newman 
##### Execute Postman regression test when Newman is installed 
Test can be executed locally or inside the container.
```
newman run <postman-collection-URL> -e <postmanEnvironment.json> -n <number-of-iterations>1 --<boolean-for exit-at-first-error>

Usage: run <collection> [options]

  URL or path to a Postman Collection.

    Options:
    
    -e, --environment <path>        Specify a URL or Path to a Postman Environment.
    -g, --globals <path>            Specify a URL or Path to a file containing Postman Globals.
    --folder <path>                 Specify folder to run from a collection. Can be specified multiple times to run multiple folders (default: )
    -r, --reporters [reporters]     Specify the reporters to use for this run. (default: cli)
    -n, --iteration-count <n>       Define the number of iterations to run.
    -d, --iteration-data <path>     Specify a data file to use for iterations (either json or csv).
    --export-environment <path>     Exports the environment to a file after completing the run.
    --export-globals <path>         Specify an output file to dump Globals before exiting.
    --export-collection <path>      Specify an output file to save the executed collection
    --postman-api-key <apiKey>      API Key used to load the resources from the Postman API.
    --delay-request [n]             Specify the extent of delay between requests (milliseconds) (default: 0)
    --bail [modifiers]              Specify whether or not to gracefully stop a collection run on encountering an errorand whether to end the run with an error based on the optional modifier.
    -x , --suppress-exit-code       Specify whether or not to override the default exit code for the current run.
    --silent                        Prevents newman from showing output to CLI.
    --disable-unicode               Forces unicode compliant symbols to be replaced by their plain text equivalents
    --global-var <value>            Allows the specification of global variables via the command line, in a key=value format (default: )
    --color <value>                 Enable/Disable colored output. (auto|on|off) (default: auto)
    --timeout [n]                   Specify a timeout for collection run (in milliseconds) (default: 0)
    --timeout-request [n]           Specify a timeout for requests (in milliseconds). (default: 0)
    --timeout-script [n]            Specify a timeout for script (in milliseconds). (default: 0)
    --ignore-redirects              If present, Newman will not follow HTTP Redirects.
    -k, --insecure                  Disables SSL validations.
    --ssl-client-cert <path>        Specify the path to the Client SSL certificate. Supports .cert and .pfx files.
    --ssl-client-key <path>         Specify the path to the Client SSL key (not needed for .pfx files)
    --ssl-client-passphrase <path>  Specify the Client SSL passphrase (optional, needed for passphrase protected keys).
    -h, --help                      output usage information
```
## Automation and scheduling
Regression testing process can be automated by setting up a cron-job.

## Known issues
##### Fix IP4 Port Forwarding Disabled issue
```
https://success.docker.com/article/ipv4-forwarding

/etc/profile.d/lang.sh: line 19: warning: setlocale: LC_CTYPE: cannot change locale (UTF-8): No such file or directory

Fix Locale error by adding the following 2 lines to /etc/environment:
 LANG=en_US.UTF-8
 LC_ALL=en_US.UTF-8
 To edit this file via SSH console, try
 sudo nano /etc/environment
```
