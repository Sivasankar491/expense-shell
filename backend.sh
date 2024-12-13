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
        echo -e "$R Please run the script with root user $N" |tee -a $LOG_FILE
        exit 1
    fi
}

VALIDATE() {
    if [ $? -ne 0 ]
    then
        echo -e "$2 is $R FAILED $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 is $G SUCCESS $N" | tee -a $LOG_FILE
    fi
}

CHECK_ROOT

dnf module disable nodejs -y &>> $LOG_FILE
VALIDATE $? "Disabling nodejs"

dnf module enable nodejs:20 -y &>> $LOG_FILE
VALIDATE $? "Enabling nodejs"

dnf list installed |grep -i nodejs &>> $LOG_FILE

if [ $? -ne 0 ]
then
    echo "NodeJS is not installed, installing nodeJS" | tee -a $LOG_FILE
    dnf install nodejs -y
    VALIDATE $? "Installing nodejs:20"
else
    echo -e "NodeJS is already installed $Y SKIPPING $N" | tee -a $LOG_FILE
fi

id expense &>> $LOG_FILE

if [ $? -ne 0 ]
then
    echo -e "expense user not exists... $G Creating $N" | tee -a $LOG_FILE
    useradd expense &>>$LOG_FILE &>> $LOG_FILE
    VALIDATE $? "Creating expense user"
else
    echo -e "expense user already exist $Y SKIPPING $N" |tee -a $LOG_FILE
fi

mkdir -p /app &>> $LOG_FILE
VALIDATE $? "Creqting app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>> $LOG_FILE
VALIDATE $? "Downloading backend application code"

cd /app
rm -rf /app/* &>> $LOG_FILE
unzip /tmp/backend.zip &>> $LOG_FILE
VALIDATE $? "Extracting the code"

npm install &>> $LOG_FILE
VALIDATE $? "Installing NPM"

cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service

dnf install mysql -y &>> $LOG_FILE
VALIDATE $? "Installing MySQL"

mysql -h mysql.kotte.site -uroot -pExpenseApp@1 < /app/schema/backend.sql &>> $LOG_FILE
VALIDATE $? "Schema loading"

systemctl daemon-reload &>> $LOG_FILE
VALIDATE $? "daemon reload"

systemctl enable backend &>> $LOG_FILE
VALIDATE $? "Enabling backend"

systemctl restart backend &>> $LOG_FILE
VALIDATE $? "Restarting backend"



