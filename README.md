# pfbackup
pfSense Backup Script (bash) for pfSense 2.3 and above. 

This bash script will remotely login to your pfSense 2.3, and newer, install and export the config.xml, with encryption, and gzip the file. It will also clean up old backups xx number of days old. A daily log file is also created. This does not backup RRD data, but can be easily modified to do so (remove the text "&donotbackuprrd=yes" from lines 49 and 55).

Execute this script with several parameters:

usage: command [ADDRESS Like 192.168.1.1] [PORT] [USER] [PASSWORD] [SAVEPATH] [ENCRYPTIONKEY (optional)] 

Inside the script there are other variables that should be modified to reflect your environments:

BACKUPDAYS="30"

PROTO="http://"

LOG="$BACKUPDIR/config-$SITE-`date +%Y%m%d`.log"

VERSION="2.3.2"


I *highly* suggest you create a dedicated "backup" user with assigned privileges to a single page - "WebCfg - Diagnostics: Backup & Restore". Do NOT use your admin account.

It should also be noted, it's possible to lock yourself out of the pfSense webGUI with repeated failed authentication attempts with this script. If this does happen, please see this page - https://doc.pfsense.org/index.php/Locked_out_of_the_WebGUI
