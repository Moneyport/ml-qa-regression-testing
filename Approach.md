# ml-qa-regression-testing Setup
This document will provide guidelines to setup the Amazon EC2 regression testing instance on AWS.

**Contents**:
- [Software List](#software-list)
- [Access and setup](#access-and-setup)
- [Install Docker](#install-docker)
- [Known issues](#known-issues)

## Software list
1. Github
1. Docker
1. Postman
1. Newman
1. nvm (NODE Version Manager)
1. npm (NODE Package Manager)
1. yum (Yellowdog Updater Modified)
1. PUTTY
1. EC2 instance on AWS (Amazon Web Server)
1. Linux (on AWS instance used) 

## Access and setup
Guidelines on how to setup the EC2 testing environment, the installation and configuration requirements.

##### AWS - EC2 Instance Detail
 To access your instance:
- Open an SSH client.
- Locate your private key file (<private-pem-filename.pem>). The wizard automatically detects the key you used to launch the instance.
- Your key must not be publicly viewable for SSH to work. Use this command if needed: (saved in .ssh) chmod 400 <private-pem-filename.pem>
- Connect to your instance using its Public DNS: <ec2-instance-name> 

## Install sendmail
Installing sendmail on EC2 (amazon linux).
```
sudo su
cd
yum install sendmail sendmail-cf m4
cd
vi /etc/mail/local-host-names
```
For more information please reference : [install-sendmail-server](https://tecadmin.net/install-sendmail-server-on-centos-rhel-server/)

##### Relay entries
1. Create 3 entries for relaying
    ```
    localhost.localdomain       RELAY
    localhost                   RELAY
    127.0.0.1                   RELAY
    ```
1. Check if correct
    ```
    vi /etc/mail/access
    ```
1. By default we allow relaying from localhost
    ```
    Connect:localhost.localdomain   RELAY
    Connect:localhost               RELAY
    Connect:127.0.0.1               RELAY
    ```

##### Generate the database
```
makemap hash /etc/mail/access.db < /etc/mail/access
```

##### Create backup folder
```
mkdir /etc/mail/backups
```

##### Create a backup of all sendmail files and settings
```
cp /etc/mail/sendmail.* /etc/mail/backups
```

##### Update sendmail.mc
Update sendmail.mc by removing the dnl - front and back
  - __dnl__ DAEMON_OPTIONS(`Port=submission, Name=MSA, M=Ea')__dnl__
    ```
    vi /etc/mail/sendmail.mc
    ```

##### Generate a new config file with the m4 command
```
m4 /etc/mail/sendmail.mc > /etc/mail/sendmail.cf
```

##### Restart the mail service
```
service sendmail restart
```

##### Find out mail server domain
```
dig -t mx awsoeasy.info
```

##### Set the HOSTNAME
Copy domain name from above and to allow SMTP to match hostname, edit file and set the HOSTNAME = to domain copied above.    
```
vi /etc/sysconfig/network
```

##### Restart the network service
```
service network restart
```

##### Change sendmail.mc
```
vi /etc/mail/sendmail.mc
```

##### Update sendmail.mc configuration
- Uncomment the line in sendmail.mc and change the value - __MASQUERADE_AS(awsoeasy.info)__
- Uncomment the line in sendmail.mc and change the value - __MASQUERADE_DOMAIN(awsoeasy.info)__

##### Verify these 2 services are stopped
```
service postfix stop
service iptables stop
```

##### Create an email.txt file
```
touch email.txt
vi email.txt

Include below entries:
    To:<recipientAddress>
    From:awsoeasy.info
    Subject<whatever>
    <text of message>
```

##### Test email
```
/usr/sbin/sendmail -t < email.txt
```

##### Send email via telnet
 If you would like to send email via telnet port 25
    ```
    yum install telnet
    ```

## Install Docker
Guidelines to install Docker on the EC2 instance

##### Update the packages on your instance
```
[ec2-user ~]$ sudo yum update -y
```

##### Install Docker
```
[ec2-user ~]$ sudo yum install docker -y
```

##### Start the Docker Service
```
[ec2-user ~]$ sudo service docker start
```

##### Add user to the docker group
Add the ec2-user to the docker group so you can execute Docker commands without using sudo.
```
[ec2-user ~]$ sudo usermod -a -G docker ec2-user
```

##### Build Image from Dockerfile
```
docker build -t <userID>/docker-newman:1 .
```

##### Add userID to the docker list
By adding the userID to the docker list you will avoid the need to type "sudo" to execute against it.
```
sudo usermod -a -G docker ec2-user
```

## Known issues
##### If the server was stopped and restarted, the Docker daemon will not be running. To start the Docker daemon:
```
sudo service docker start
```
