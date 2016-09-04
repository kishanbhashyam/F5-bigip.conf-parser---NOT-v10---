#!/bin/bash
# Original Author: Kishan Bhashyam
# Last modified date: 28 July 2016
# Version: V0.01
# Purpose: This script will pull zipped LB config files, unzip it and parse Engine.pl to gain useful output.
#
# USAGE: ./MasterScript.sh
#

#LIST ALL LB's
printf "\n"
printf "\n"
printf "\n"
cat /..../......./F5conf/LBList.txt
printf "\n"
printf "\n"
printf "\n"
#printf "Load Balancer list printed Successfully"

#MAKE UNZIP FOLDER AVAILABLE FOR LB CONFIG
rm -r -f /..../......./F5conf/unzip
mkdir /..../......./F5conf/unzip
chmod 777 /..../......./F5conf/unzip
#printf "Fresh unzip folder made available"

#IMPORT .UCS FILE
read -p "Enter LB Name:" LB
cp /..../......./F5conf/F5LoadBalancers/$LB/* /..../......./F5conf/unzip/
#printf ".UCS File Copied succssfully"

#UNZIP .UCS FILE
cd /..../......./F5conf/unzip/
tar -xvzf /..../......./F5conf/unzip/*
#printf ".UCS file unzipped successfully to /home/t816874/F5conf/unzip/*"

#Static Variable
SOCDIR=/..../......./F5conf/
DATE=$(date +%Y-%m-%d)
LOGFILE=$SOCDIR/F5Output/f5script.log


#Remove Old Output Files
rm -f $SOCDIR/F5Output/*
#printf "All files from F5Output removed successfully"

#Use F5 config file
find $SOCDIR/unzip/config/ -type f -name "bigip.conf" | while read FILE; do
#printf "bigip.conf file found inside config folder"

#Parse Engine script on the F5 conf file.
$SOCDIR/Engine.pl $FILE >> $SOCDIR/F5Output/f5ipmapping-$DATE.csv
                done


                echo no backup file existed for $HOST for $(date) >>$LOGFILE
#printf "Engine.pl parsed Successfully"

#Regex for Output.
awk -F "," '{if ($3 != "" && $5 != "") print $3 "," $5}' $SOCDIR/F5Output/f5ipmapping-$DATE.csv > $SOCDIR/F5Output/tempoutput1.csv
sed 's/\/[a-zA-Z].*\///g' $SOCDIR/F5Output/tempoutput1.csv | sort -u | sort -n > $SOCDIR/F5Output/tempoutput2.csv
awk -F "," '{if ($1 != "0.0.0.0") print $1 "," $2}' $SOCDIR/F5Output/tempoutput2.csv > $SOCDIR/F5Output/f5finaloutput-$DATE.csv
#printf "No issues with regex"

#/usr/bin/find $SOCDIR/csv/f5* -mtime +$DAYSOLD -exec rm -f {} \;
