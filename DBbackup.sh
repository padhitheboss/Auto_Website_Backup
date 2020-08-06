#!/bin/bash
TODAY="$(date +"%d-%m-%Y")"
# Define Backup Folder
BACKUP_PATH="$HOME/backups/$TODAY"

# Define user,password,dbname.dbhost for database backup
DB_NAME="DATABASE_NAME_HERE"
DB_USER="DATABASE_USERNAME_HERE"              #Backup All Database require root privilage
DB_PASS="DATABASE_PASSWORD_HERE"
DB_HOST="deevehs.cneuw48yd50i.ap-south-1.rds.amazonaws.com"              #If sql server is installed on your local machine set DB_HOST="localhost" OR "127.0.0.1"

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


function dbrestore () {
    clear
    echo "Starting Database Restore...."
    echo "Enter Path of .sql file to restore"
    read PATH
    mysql -u $DB_USER -h $DB_HOST --password=$DB_PASS < $PATH
    echo"Backup Restored"
}

function seldbbackup () {
    clear
    echo "Starting Database Backup..."
    if [ $DB_NAME == "DATABASE_NAME_HERE" ]; then
        echo "Enter Database Name To Backup:"
        read DB_NAME
    fi
    mysqldump -h $DB_HOST -u $DB_USER --password=$DB_PASS $DB_NAME > /$BACKUP_PATH/$DB_NAME.sql
    echo "Database Backup Finished"
}

function fulldbbackup () {
    clear
    echo "Starting Database Backup..."
    mysqldump --all-databases --single-transaction --quick --lock-tables=false -h $DB_HOST -u $DB_USER --password=$DB_PASS >  /$BACKUP_PATH/completedb_backup.sql
    echo "Database Backup Finished"

}

function mainmenu () {
    clear
    echo " "
    echo "Backup Database"
    echo " "
    echo "Choose a option from below:"
         echo 1. Complete Database Backup
         echo 2. Selected Database Backup
         echo 3. Database Restore
         echo 4. Exit
    echo " "
    echo -n "Enter Option No.:"
    read option
    case $option in
        1)
            fulldbbackup
            read -n 1 -p "<Enter> for main menu"
            mainmenu
        ;;
        2)
            seldbbackup
            read -n 1 -p "<Enter> for main menu"
            mainmenu
        ;;
        3)
            dbrestore
            read -n 1 -p "<Enter> for main menu"
            mainmenu
        ;;
        4)
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
