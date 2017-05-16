#!/bin/bash
# Created 5/15/2017 by motonuke

if (( $# != 6 )); then
echo ""
echo "Illegal number of parameters"
echo ""
echo "usage: command [ADDRESS Like 192.168.1.1] [PORT] [USER] [PASSWORD] [ENCRYPTIONKEY] [SAVEPATH]"
exit
else

SITE=$1
PORT=$2
USERNAME=$3
PASSWORD=$4
ENCSTRING=$5
BACKUPDIR=$6
GZIP="/bin/gzip"
FIND="/usr/bin/find"
BACKUPDAYS="30"
PROTO="http://"
LOG="$BACKUPDIR/config-$SITE-`date +%Y%m%d`.log"
FILENAME="$BACKUPDIR/config-$SITE-`date +%Y%m%d%H%M%S`.xml"

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

wget --keep-session-cookies --load-cookies cookies.txt --no-check-certificate --post-data "Submit=download&donotbackuprrd=yes&encrypt=on&encrypt_password=$ENCSTRING&__csrf_magic=$(head -n 1 csrf2.txt)" $PROTO$SITE:$PORT/diag_backup.php -O $FILENAME
		
if [ -e $FILENAME ]; then

	if [[ $( grep "Username or Password incorrect" "$FILENAME") ]]; then echo "Config export failed, please check your parameters" >> $LOG ; 
		else echo "Detected successful logon, assuming export file is good, " >>$LOG; $GZIP $FILENAME; 
		fi
	
	else echo "$FILENAME Not Found, something went wrong" >> $LOG; fi
echo "" >> $LOG

$FIND $BACKUPDIR -type f -name "*.xml.gz" -mtime +$BACKUPDAYS -exec rm {} \;
fi
