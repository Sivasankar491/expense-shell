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
        echo -e "$2 is $R FAILED $N"
        exit 1
    else
        echo -e "$2 is $G SUCCESS $N"
    fi
}

CHECK_ROOT

dnf list installed|grep -i mysql
VALIDATE $? "MySQL already installed"

dnf install mysql-server -y
VALIDATE $? "MySQL installation"

systemctl enable mysqld
VALIDATE $? "Enable MYSQL"

systemctl start mysqld
VALIDATE $? "Starting MYSQL"

mysql_secure_installation --set-root-pass ExpenseApp@1 -e "show databases;"

if [ $? -ne 0 ]
then
    echo "MySQL root password is not setup, setting now"
    mysql_secure_installation --set-root-pass ExpenseApp@1
    VALIDATE $? "Setting up root password"
else
    echo -e "MySQL root password is already setup, $Y SKIPPING $N"
fi
    










