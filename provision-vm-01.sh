#!/bin/bash

# What time zone switch to
TZONE="Europe/Minsk"

# Message displayed while console login in
MESSAGE="Unauthorized access to this machine is prohibited
Press <Ctrl-D> if you are not an authorized user!"

# Banner displayed while ssh login in
BANNER="********************************************************************
*                                                                  *
* This system is for the use of authorized users only.  Usage of   *
* this system may be monitored and recorded by system personnel.   *
*                                                                  *
******************************************************************** "

#nginx repository configuration text
REPOTEXT="[nginx-mainline]
name=nginx mainline repo
baseurl=http://nginx.org/packages/mainline/centos/\$releasever/\$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true"

#Webpage HTML text
WEB="<!DOCTYPE html>
<html>
<body>
<center>
<h1>Custom webpage for lab01</h1>
</center>
</body>
</html>"

#What service you wanna add in firewall config
SERVICE="http"



function timezone_set {

        if [[ "$(timedatectl)" == *$TZONE* ]]; then 
		echo "Time zone $TZONE is already set"
	else
        	timedatectl set-timezone $TZONE
		echo "Time zone is switched to $TZONE"
	fi
}

function chronyd_on {

        if [[ $(systemctl is-enabled chronyd) == enabled ]];
        then
                echo "Chrony service is enabled!"
        else
                echo "Chrony service is disabled and inactive (dead). Enabling and activating..."
                systemctl enable --now chronyd
        fi
}

function add_message {
	
	echo "Adding message of a day and banner text"
	echo "$MESSAGE" | tee /etc/motd > /dev/null

	echo "$BANNER" | tee /etc/issue > /dev/null
	if ! grep -q "Banner /etc/issue" /etc/ssh/sshd_config; then
		echo "Banner /etc/issue" | tee -a /etc/ssh/sshd_config > /dev/null
		systemctl restart sshd
	fi
}

function nginx_config {

        #Installing yum-utils
        if yum list installed | grep -q "yum-utils"; then
                echo "yum-utils is already installed! Nothing to do."
        else
                yum install yum-utils -y > /dev/null
        fi


        #Configuring nginx repository   
        echo "$REPOTEXT" | tee /etc/yum.repos.d/nginx.repo > /dev/null


        #Installing nginx-mainline
        if yum list installed | grep -q "nginx-mainline"; then
                echo "NGINX-mainline is already installed! Nothing to do."
        else
                echo "Installing NGINX-mainline"
                yum install nginx -y &> /dev/null
        fi


        #Adding custom webpage to standart nginx directory
        echo "Setting up custom webpage"
        echo "$WEB" > /usr/share/nginx/html/index.html


        #Enabling nginx
        if [[ $(systemctl is-enabled nginx) == enabled ]]; then
                echo "NGINX is enabled! Nothing to do"
        else
                echo "NGINX is disabled and inactive (dead). Enabling and activating..."
                systemctl enable --now nginx
        fi
}

function firewall_add_serv {

        if [[ "$(firewall-cmd --list-services)" == *$SERVICE* ]]; then
                echo "$SERVICE service is already added in firewall configuration"
        else
                echo "Adding $SERVICE service in firewall configuration"
                firewall-cmd --add-service $SERVICE --permanent >/dev/null 2> /dev/null
                firewall-cmd --reload > /dev/null
        fi
}


timezone_set 		# Set timezone to Europe/Minsk
chronyd_on		# Enable chronyd
add_message 		# Set banner and motd
nginx_config 		# Setting up nginx servers
firewall_add_serv 	# Openning SERVICE in firewall   

echo "OK"
