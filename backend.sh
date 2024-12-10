#!/bin/bash

LOGS_FOLDER="/var/log/messages"
SCRIPT_NAME=$(echo $0 |cut -d "." -f 1)
TIME_STAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log"

USER_ID=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

CHECK_ROOT() {
    if [ $USER_ID -ne 0 ]
    then
        echo -e "$R Please run the script with root user $N"
        exit 1
    fi
}

VALIDATE() {
    if [ $? -ne 0 ]
    then
        echo -e "$2 is $R FAILED $N"
        exit 1
    else
        echo -e "$2 is $G SUCCESS $N"
    fi
}

CHECK_ROOT

dnf module disable nodejs -y
VALIDATE $? "Disabling nodejs"

dnf module enable nodejs:20 -y
VALIDATE $? "Enabling nodejs"

dnf list installed |grep -i nodejs

if [ $? -ne 0 ]
then
    echo "NodeJS is not installed, installing nodeJS"
    dnf install nodejs -y
    VALIDATE $? "Installing nodejs:20"
else
    echo -e "NodeJS is already installed $Y SKIPPING $N"
fi
