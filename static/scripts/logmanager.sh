#!/bin/bash

# The MIT License (MIT)
#
# Copyright (c) 2014 Gluu
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# Script to compress logfiles over defined periodicity
#Author : Vishwa Ranjan

#Variable Definition
KEEPDAYS1=1   #for compression
KEEPDAYS2=15  #for deletion

if [ -h /opt/opends ]; then
        OPENDX="opends"
else
        OPENDX="opendj"
fi

DIRS="/opt/idp/logs/ /opt/tomcat/logs/ /opt/tomcat/temp /opt/$OPENDX/logs/ /opt/vds/vds_server/logs/ /var/log/ /var/log/httpd/ /var/log/puppet/ /var/log/shibboleth/ /var/log/cups/ /var/removedldif/ /opt/$OPENDX/backup_$OPENDX/ /opt/$OPENDX/backup_$OPENDX/userRoot/ /opt/$OPENDX/backup_$OPENDX/schema/ /opt/$OPENDX/backup_$OPENDX/site/ /opt/$OPENDX/backup_$OPENDX/tasks/ /opt/$OPENDX/backup_$OPENDX/config/ /opt/$OPENDX/backup_$OPENDX/ /opt/$OPENDX/config/archived-configs /opt/ds01/backup_opendj /opt/ds02/backup_opendj /home/ldap/backup_opendj"

PWD=`pwd`
PWD1=$PWD
TEMPDIR="/tmp/gluumanager"
mkdir $TEMPDIR >> /opt/gluu/logs/logmanager.log 2>&1
cd $TEMPDIR
echo "$(date) : Changing to TEMP Directory" $TEMPDIR >> /opt/gluu/logs/logmanager.log
#compression Section
echo "$(date) : Starting Compression">> /opt/gluu/logs/logmanager.log
for dir in $DIRS
do
 if [ -d "$dir" ]; then
 FILES=`find $dir -type f -mtime +$KEEPDAYS1 ! -name "*.gz" |xargs ls `
 fi
 for fname in $FILES
   do
           echo "$(date) : Compressing file" $fname >> /opt/gluu/logs/logmanager.log
           gzip --best --force $fname >> /opt/gluu/logs/logmanager.log 2>&1
   done
done
# To take care of unintentional compression
gzip -d /opt/$OPENDX/logs/server.out.gz >> /opt/gluu/logs/logmanager.log 2>&1
gzip -d /opt/$OPENDX/logs/server.pid.gz >> /opt/gluu/logs/logmanager.log 2>&1

# Deletion Section
echo "$(date) : Starting Deletion">> /opt/gluu/logs/logmanager.log
for dir in $DIRS
do
 if [ -d "$dir" ]; then
 FILES=`find $dir -name "*gz" -type f -mtime +$KEEPDAYS2 |xargs ls `
 fi
 for fname in $FILES
   do
           echo "$(date) : Deleting file" $fname >> /opt/gluu/logs/logmanager.log
           rm -f $fname >> /opt/gluu/logs/logmanager.log 2>&1
   done
done
echo "$(date) : Changing back to working  Directory" $PWD1 >> /opt/gluu/logs/logmanager.log
cd $PWD1 >> /opt/gluu/logs/logmanager.log 2>&1
echo "$(date) : Removing Temp Directory" $TEMPDIR >> /opt/gluu/logs/logmanager.log
rm -r  $TEMPDIR >> /opt/gluu/logs/logmanager.log 2>&1
