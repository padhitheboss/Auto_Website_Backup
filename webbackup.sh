#!/bin/bash
TODAY="$(date +"%d-%m-%Y")"
# Define The Site Path
SITES_PATH="/var/www/html/ehsprints"
# Define Backup Folder
BACKUP_PATH="$HOME/LiveSite_Backup/$TODAY"
mkdir -p $BACKUP_PATH
# Define user,password,dbname.dbhost for database backup
DB_NAME="DATABASE_NAME_HERE"
DB_USER="DATABASE_USERNAME_HERE"
DB_PASS="DATABASE_PASSWORD_HERE"
DB_HOST="DATABASE_HOSTNAME_HERE"
if [ ! -d "$BACKUP_PATH" ] && [ "$(mkdir -p $BACKUP_PATH)" ]; then
    echo "BACKUP_PATH is not found at $BACKUP_PATH. The script can't create it, either!"
    echo 'You may want to create it manually'
    exit 1
fi


if [ ! -d "$BACKUP_PATH" ] && [ "$(mkdir -p $BACKUP_PATH)" ]; then
    echo "BACKUP_PATH is not found at $BACKUP_PATH. The script can't create it, either!"
    echo 'You may want to create it manually'
    exit 1
fi

if [ $DB_HOST == "DATABASE_HOSTNAME_HERE" ]; then
    DB_HOST='localhost'
    echo "As No Hostname for database server is provided it is set to default i.e localhost"
fi

if [ $DB_USER == "DATABASE_USERNAME_HERE" ]; then
    echo "Enter Database User Name:"
    read DB_USER
    echo "Enter Password For User $DB_USER"
    read DB_PASS
fi

function dbbackup(){
    echo "Starting Database $DB_NAME Backup..."
    if [ $DB_NAME == "DATABASE_NAME_HERE" ]; then
        echo "Enter Database Name To Backup:"
        read DB_NAME
    fi
    mysqldump -h $DB_HOST -u $DB_USER --password=$DB_PASS $DB_NAME > /$BACKUP_PATH/DB_backup.sql
    echo "Database Backup Finished"
}

function wpfilesbackup(){
    echo "Starting Web Files Backup ......"
    cd $BACKUP_PATH
    tar -zcvf web_files.tar.gz $SITES_PATH
    echo "Web Files Backup Finished"
}

function s3backup(){
    echo "Copping Backup Files to S3...... "
    echo "Enter link of s3 directory:(ex:S3://link_to_dir):"
    aws s3 cp --recursive LiveSite_Backup/$TODAY $s3link/$TODAY
    echo "Done"
}

function mainmenu(){
    clear
    echo " "
    echo "Backup Web Files And Database" 
    echo " "
    echo "Choose a option from below:" 
         echo 1. Complete Backup
         echo 2. Complete Backup To S3 Bucket 
         echo 3. Database Only Backup
         echo 4. Web Files Only Backup
         echo 5. Backup Current Backup To S3 Bucket
         echo 6. Exit
    echo " "
    echo -n "Enter Option No.:"
    read option
    case $option in
        1)
            dbbackup
            wpfilesbackup
            read -n 1 -p "<Enter> for main menu"
            mainmenu
        ;;

        2)
            dbbackup
            wpfilesbackup
            s3backup
            read -n 1 -p "<Enter> for main menu"
            mainmenu
        ;; 

        3)
            dbbackup
            read -n 1 -p "<Enter> for main menu"
            mainmenu
        ;;
        4)
            wpfilesbackup
            read -n 1 -p "<Enter> for main menu"
            mainmenu
        ;;  
        5)
            s3backup
            read -n 1 -p "<Enter> for main menu"
            mainmenu
        ;;
        6)
		function goout () {
			TIME=2
			echo " "
			echo Leaving the system ......
			sleep $TIME
			exit 0
		}
		goout
	;;

esac
}
mainmenu    
