#!/bin/bash
#

# Simple script for creating backups with Duplicity.
# (inspired by http://wiki.hetzner.de/index.php/Backup )

# Full backups are made on the 1st day of each month or with the 'full' option.
# Incremental backups are made on any other days.
#
# USAGE: backup.sh [full]
#

BDIRS="etc home"
#BDIRS="etc home root usr\/local"

# eclude list must be written in /etc/duplicity/duplicity-exclude-$DIR.conf

# Setting the pass phrase to encrypt the backup files. Will use symmetrical keys in this case.
PASSPHRASE='***'
export PASSPHRASE

# set user for conneting to backup server 
BUSER='backupuser'
# set backup server
BHOST='backupserver.example.com'

# Setting the password for the Backup account that the
# backup files will be transferred to.
#BPASSWORD='yourpass'

LOGDIR='/var/log/duplicity'

########################################################################################################################
############################## NO NEED TO CHANGE ANYTHING BELOW ########################################################
########################################################################################################################

BACKUP_DIR=backup_duplicity
TDIR=`hostname -f`
# Set protocol (use scp for sftp and ftp for FTP, see manpage for more)
BPROTO=scp
# encryption algorithm for gpg, disable for default (CAST5)
# see available ones via 'gpg --version'
ALGO=AES

##############################

DUPLICITY=`which duplicity`

if [ ! -x "${DUPLICITY}" ]; then
  echo "ERROR: duplicity not installed, that's gotta happen first!" >&2
  exit 1
fi

# get day of the month
DATE=`date +%d`

if [ $ALGO ]; then
 GPGOPT="--gpg-options '--cipher-algo $ALGO'"
fi

if [ $BPASSWORD ]; then
 BAC="$BPROTO://$BUSER:$BPASSWORD@$BHOST"
else
 BAC="$BPROTO://$BUSER@$BHOST"
fi

# Check to see if we're at the first of the month.
# If we are on the 1st day of the month, then run
# a full backup. If not, then run an incremental
# backup.

if [ $DATE = 01 ] || [ "$1" = 'full' ]; then
 TYPE='full'
else
 TYPE='incremental'
fi

for DIR in $BDIRS
do
  # chech for exclude files
  EXCLUDELIST="/etc/duplicity/duplicity-exclude-$DIR.conf"

  if [ -f $EXCLUDELIST ]; then
    EXCLUDE="--exclude-filelist $EXCLUDELIST"
  else
    EXCLUDE=''
  fi
 
  # clean up DIR  
  DIR_CLEANED=`echo $DIR | tr \/ _`

  # first remove everything older than 2 months
  CMD="$DUPLICITY remove-older-than 2M -v5 --force    ${BAC}/${BACKUP_DIR}/${TDIR}/${DIR} >> ${LOGDIR}/${DIR_CLEANED}.log"
  echo "Executing:"
  echo "    $CMD"
  eval $CMD

  # do a backup
  CMD="$DUPLICITY $TYPE -v5 $GPGOPT $EXCLUDE /${DIR}  ${BAC}/${BACKUP_DIR}/${TDIR}/${DIR} >> ${LOGDIR}/${DIR_CLEANED}.log"
  echo "Executing:"
  echo "    $CMD"
  eval $CMD

done

# Unsetting the confidential variables
unset PASSPHRASE
unset BPASSWORD
