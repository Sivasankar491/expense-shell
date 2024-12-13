#!/bin/bash

USER_ID=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

LOGS_FOLDER="/var/log/expense/"
SCRIPT_NAME=$(echo $0|cut -d "." -f1)
TIME_STAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME-$TIME_STAMP.log"

mkdir -p $LOGS_FOLDER

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
        echo -e "$2 is $R FAILED $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 is $G SUCCESS $N"| tee -a $LOG_FILE
    fi
}

CHECK_ROOT

dnf list installed|grep -i mysql &>> $LOG_FILE 

if [ $? -ne 0 ]
then
    dnf install mysql-server -y &>> $LOG_FILE
    VALIDATE $? "MySQL installation"
else
    echo -e "MySQL is already installed $Y SKIPPING $N"
fi

systemctl enable mysqld &>> $LOG_FILE
VALIDATE $? "Enable MYSQL"

systemctl start mysqld &>> $LOG_FILE
VALIDATE $? "Starting MYSQL"

mysql_secure_installation --set-root-pass ExpenseApp@1 -e "show databases;" &>> $LOG_FILE

if [ $? -ne 0 ]
then
    echo "MySQL root password is not setup, setting now" &>> $LOG_FILE
    mysql_secure_installation --set-root-pass ExpenseApp@1
    VALIDATE $? "Setting up root password"
else
    echo -e "MySQL root password is already setup, $Y SKIPPING $N" | tee -a $LOG_FILE
fi
    










