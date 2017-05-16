# pfbackup
pfSense Backup Script (bash) for pfSense 2.3 and above. 

This bash script will remotely login to your pfSense 2.3, and newer, install and export the config.xml, with encryption, and gzip the file. It will also cleanup old backups xx number of days old. A daily log file is also created.

Execute this script with several parameters:

usage: command [ADDRESS Like 192.168.1.1] [PORT] [USER] [PASSWORD] [ENCRYPTIONKEY] [SAVEPATH]

Inside the script there are other variables that should be modified to reflect your environments:

BACKUPDAYS="30"

PROTO="http://"

LOG="$BACKUPDIR/config-$SITE-`date +%Y%m%d`.log"


I *highly* suggest you create a dedicated "backup" user with assigned privileges to a single page - "WebCfg - Diagnostics: Backup & Restore". Do NOT use your admin account.

It should also be noted, it's possible to lock yourself out of the pfSense webgui with repeated failed authentication attempts with this script. If this does happen, please see this page - https://doc.pfsense.org/index.php/Locked_out_of_the_WebGUI
