#!/bin/bash

service ssh start

function NIPE()
{
    echo "[ ! ] Checking if you are anonymous..."
    sudo perl nipe.pl restart 
    ADDR=$(sudo perl nipe.pl status | grep Ip: | awk '{print $3}') > /dev/null 2>&1
    COUNTRY=$(geoiplookup $ADDR | awk '{print $4}' | sed 's/,//g') > /dev/null 2>&1

    if [ $COUNTRY == "IL" ];
    then
        echo "[ ! ]You are non anonymous! EXIT!"
		exit
    else
        echo "[ + ] You are anonymous! Spoofed Country: $COUNTRY"
    fi
}

function INSTALL_NIPE()
{
    git clone https://github.com/htrgouvea/nipe > /dev/null 2>&1
    cd nipe
    cpanm --installdeps . > /dev/null 2>&1
    sudo cpan install try::Tiny Config::Simple JSON > /dev/null 2>&1
    sudo perl nipe.pl install > /dev/null 2>&1
    NIPE
}

function START()
{
	echo "[ ! ]Please type the username for the remote server: $SSH_USER"
	read SSH_USER
    echo "[ ! ] Please provide the ip address of the remote server: $SSH_IP"
    read SSH_IP
    echo "[ ! ] Please provide the password for the SSH service on the remote server: $SSH_PASS"
    read -s SSH_PASS
    echo "[ + ] Moving on to relevent installations..."
    INSTALL_NIPE
}

figlet "First Project"
START

function WHOIS_INSTL()
{
		if which "whois" &> /dev/null
		then
		echo "[ ! ] Whois Already Installed!"
		else
		echo "[ ! ] Whois Not downloded! installing..."
		sudo apt-get install whois -y
		fi
}
WHOIS_INSTL

function SSHPASS_INSTL()
{
		if which "sshpass" &> /dev/null
		then
		echo "[ ! ] SSHPASS Already Installed!"
		else
		echo "[ ! ] SSHPASS Not downloded! installing..."
		sudo apt-get install sshpass -y
		fi
}
SSHPASS_INSTL

function SSH_WHOIS()
{
		sudo sshpass -p "$SSH_PASS" ssh -o StrictHostKeyChecking=no $SSH_USER@$SSH_IP whois $SSH_IP >> /home/$SSH_USER/Desktop/whois.txt
		echo "[ ! ] WhoIS of the Remote IP success!"
}
SSH_WHOIS

function SSH_NMAP()
{
	sudo sshpass -p "$SSH_PASS" ssh -o StrictHostKeyChecking=no $SSH_USER@$SSH_IP nmap $SSH_IP >> /home/$SSH_USER/Desktop/nmap.txt
	echo "[ ! ] NMAP of the Remote IP success!"
}
SSH_NMAP

function SSH_INFO()
{
	UPTIME=$(sudo sshpass -p "$SSH_PASS" ssh -o StrictHostKeyChecking=no $SSH_USER@$SSH_IP uptime | awk '{print "time up: "$1 $2}')
	IP=$(sudo sshpass -p "$SSH_PASS" ssh -o StrictHostKeyChecking=no $SSH_USER@$SSH_IP ifconfig | grep broadcast | awk '{print $2}')
	REAL=$(sudo sshpass -p "$SSH_PASS" ssh -o StrictHostKeyChecking=no $SSH_USER@$SSH_IP whois $IP | grep -i country | sed 's/\ //g')
	echo "[ + ] $UPTIME the ip is: $IP, the country is: $REAL"
}
SSH_INFO

function WHOIS_PORTS()
{
	figlet WHOIS FORMAT
	sudo sshpass -p "$SSH_PASS" ssh -o StrictHostKeyChecking=no $SSH_USER@$SSH_IP whois $SSH_IP | sed 's/#//g'
	figlet NMAP FORMAT
	sudo sshpass -p "$SSH_PASS" ssh -o StrictHostKeyChecking=no $SSH_USER@$SSH_IP nmap nmap -p 1-65535 $SSH_IP
}
WHOIS_PORTS
