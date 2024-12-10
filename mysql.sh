#!/bin/bash


USER_ID=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

CHECK_ROOT() {
    if [ $USER_ID -ne 0 ]
    then    
        echo -e "$R Please run the script with root user$N"
        exit 1
    fi
}

VALIDATE() {
    if [ $1 -ne 0 ]
    then
        echo -e "$2 installation is $R FAILED $N"
        exit 1
    else
        echo -e "$2 installation is $G SUCCESS $N"
    fi
}

CHECK_ROOT

dnf install mysql-server -y
VALIDATE $? MySQL






