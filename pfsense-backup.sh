#!/bin/bash
# Created 5/15/2017 - motonuke
# Last update 5/17/2017 - motonuke

if [ "$#" -lt 5 ] || [ "$#" -gt 6 ]; then
echo ""
echo "Illegal number of parameters"
echo ""
echo "Looking for 5 or 6 parameters, you provided $#"
echo ""
echo "usage: command [ADDRESS Like 192.168.1.1] [PORT] [USER] [PASSWORD] [SAVEPATH] [ENCRYPTIONKEY (optional)]"
exit
else

SITE=$1
PORT=$2
USERNAME=$3
PASSWORD=$4
BACKUPDIR=$5
if [ "$6" ] ; then ENCSTRING=$6; fi
GZIP="/bin/gzip"
FIND="/usr/bin/find"
BACKUPDAYS="30"
PROTO="http://"
LOG="$BACKUPDIR/config-$SITE-`date +%Y%m%d`.log"
FILENAME="$BACKUPDIR/config-$SITE-`date +%Y%m%d%H%M%S`.xml"
VERSION="2.3.2"
VERMSG="\nAttempting to backup pfSense Version $VERSION\n"
FAIL="Config export failed, please check that your Username, Password, or Version parameters are valid"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "=======================================================================================================" >> $LOG
echo "`date`" >> $LOG
echo "" >> $LOG
echo "Parameters Used:" >> $LOG
echo "$PROTO - $SITE - $PORT - $USERNAME - $BACKUPDIR" >> $LOG
echo "" >> $LOG
echo "Backup Filename - $FILENAME".gz >> $LOG
echo "" >> $LOG

wget -qO- --keep-session-cookies --save-cookies cookies.txt --no-check-certificate $PROTO$SITE:$PORT/diag_backup.php | grep "name='__csrf_magic'" | sed 's/.*value="\(.*\)".*/\1/' > csrf.txt

wget -qO- --keep-session-cookies --load-cookies cookies.txt --save-cookies cookies.txt --no-check-certificate --post-data "login=Login&usernamefld=$USERNAME&passwordfld=$PASSWORD&__csrf_magic=$(cat csrf.txt)" $PROTO$SITE:$PORT/diag_backup.php | grep "name='__csrf_magic'" | sed 's/.*value="\(.*\)".*/\1/' > csrf2.txt        


if [ $(echo "${VERSION//.}") -ge 233 ] ; then
	echo -e $VERMSG
	echo -e $VERMSG >> $LOG
	if [ $ENCSTRING ]; then wget --keep-session-cookies --load-cookies cookies.txt --no-check-certificate --post-data "download=download&donotbackuprrd=yes&encrypt=on&encrypt_password=$ENCSTRING&__csrf_magic=$(head -n 1 csrf2.txt)" $PROTO$SITE:$PORT/diag_backup.php -O $FILENAME
	else wget --keep-session-cookies --load-cookies cookies.txt --no-check-certificate --post-data "download=download&__csrf_magic=$(head -n 1 csrf2.txt)" $PROTO$SITE:$PORT/diag_backup.php -O $FILENAME
	fi
else 
	echo -e $VERMSG
	echo -e $VERMSG >> $LOG
	if [ $ENCSTRING ]; then wget --keep-session-cookies --load-cookies cookies.txt --no-check-certificate --post-data "Submit=download&donotbackuprrd=yes&encrypt=on&encrypt_password=$ENCSTRING&__csrf_magic=$(head -n 1 csrf2.txt)" $PROTO$SITE:$PORT/diag_backup.php -O $FILENAME
	else wget --keep-session-cookies --load-cookies cookies.txt --no-check-certificate --post-data "Submit=download&donotbackuprrd=yes&__csrf_magic=$(head -n 1 csrf2.txt)" $PROTO$SITE:$PORT/diag_backup.php -O $FILENAME
	fi
fi
		
if [ -e $FILENAME ]; then
	if [ $ENCSTRING ]; then 
		echo "Found Encryption Key, checking for good file"
		if [[ $( grep "BEGIN config.xml" "$FILENAME") ]]; then
			PASS="Detected successful encrypted config.xml export, assuming export file is good"
			echo $PASS
			echo $PASS >> $LOG
			$GZIP $FILENAME
			else  
			echo $FAIL
			echo $FAIL >> $LOG
		fi
		else
		echo "No Encryption specified, checking for good file"
		if [[ $( grep "<pfsense>" "$FILENAME") ]]; then  
			PASS="Detected successful unencrypted config.xml export, assuming export file is good"
			echo $PASS
			echo $PASS >> $LOG
			$GZIP $FILENAME
			else  
			echo $FAIL
			echo $FAIL >> $LOG
		fi
		
		
	fi
	else echo "$FILENAME Not Found, something went wrong" >> $LOG
fi

echo "" >> $LOG
# Cleanup
echo "Cleaning up files and Backups older than $BACKUPDAYS days..."
$FIND $BACKUPDIR -type f -name "*.xml.gz" -mtime +$BACKUPDAYS -exec rm {} \;
rm $DIR/csrf*.txt
rm $DIR/cookies.txt

fi
