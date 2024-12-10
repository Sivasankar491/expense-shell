#!/bin/bash


USER_ID=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

CHECK_ROOT() {
    if [ $USER_ID -ne 0 ]
    then    
        echo -e "$Y Please run the script with root user$N"
        exit 1
    fi
}

VALIDATE() {
    if [ $? -ne 0 ]
    then
        echo "MySQL isn't installed"
        exit 1
    fi
}

CHECK_ROOT




