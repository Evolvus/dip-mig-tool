#!/bin/bash
##
##  FILE NAME		= execute.sh						            ##
##  DESCRIPTION         = This script is used to execute sql 		    ##
##  AUTHOR		= Alavudeen
##  DATE OF CREATION    = 01-06-2014							    ##
##  NOTE		= ##This is the main program that drives this tool. The flow is defined here
##					The actual logic will be in functions
##--**************************************************************************************--##



#External scripts whose variables and functions will be used by this main program

source config.env

MIG_PATH=$ORIGINAL_MIG_PATH
source functions.sh

#Global variables is by Choice
#
#Holds the  NAME of selected Country
ctry=""
#Holds the  ID of selected Country
ctry_id=""
#Holds the DB link of the  selected Country
dbconf=""

#Holds the current container selected
spool_contr=""
#holds the filename of the container
spool_contr_file=""

#IF THE COUNTRY ID IS PROVIDED IN THE PARAMETER THEN DIRECTLY TO CONTAINER MENU
#IF NOT PROVIDED THEN MOVE TO COUNTRY MENU
if ! [[ "$1" =~ ^[0-9]+$ && "$1" -le $NO_CTRY ]]
then
	print_header
	choose_country
else
	dbconf_var="CTRY_"$1"_DB"
	check_critical_var "${!dbconf_var}" $dbconf_var

	dbconf=${!dbconf_var}
	ctry_var="CTRY_"$1"_NAME"
	ctry=${!ctry_var}
	ctry_id=$1
	country_wise
	log_info "Selected from Parameter the country $ctry"

fi
print_header

#ASK FOR PASSWORD; IN MEMORY NOT LOGGED OR STORED; SAFE HERE;

if [ "$DB_PASS" == "" ]; then
	stty -echo
	read -p "ENTER PASSWORD FOR DATABASE ($dbconf): " enter_pass
	stty echo
	DB_PASS=$enter_pass
	echo ""
fi


		


echo "ACTION : CHOOSE SPOOL CONTAINER"

choose_registered_spool_containers

log_info "Executing SQLs from Container $spool_contr_name with file $spool_contr_file"

echo " "
cat "$CONTAINER_PATH/$spool_contr_file" 2> $LOG_PATH/$LOG_ERROR_FILE 

echo " "
read -n1 -p "Do you want to transfer to SFTP Server @ $sftpconf? [y,n]" askspool
#LOOP THROUGH EACH LINE OF CONTAINER FILE AND EXECUTE THE SQL FILE
while read -r line
do

    name=$line
	f1=${line:0:1}
	if [ "$f1" == "#" ] || [ "$f1" == "" ]; then

		continue
	fi
	read sqlfile spoolfile sftppath <<<$(IFS=" "; echo $name)

	sqlexec="$SQL_PATH/$sqlfile"
	#Removes control M characters, nul characters and blank lines
	perl -pi -e 's/\r//g' $sqlexec
	perl -pi -e 's/\000//g' $sqlexec
	perl  -i -n -e'print if /\S/' $sqlexec

	log_info "Executing SQL file   at `date`  $sqlexec"

#	sqlplus -s $dbconf/$DB_PASS @$sqlexec
	sleep  $[RANDOM%5+1]
	echo "************************************"
	echo "Please review below information before submitting the files"
	echo "Total Number of rows spooled `wc -l $OUTPUT_PATH/$spoolfile`"
	echo "First two Rows of the spool"
	head -2 "$OUTPUT_PATH/"$spoolfile
	echo " "
	
	if [[ $askspool == "Y" || $askspool == "y" ]]; then
		if [[ "$sftppath" != "" ]]; then
			spoolfile="$OUT_PATH/"$spoolfile
			log_info "SFTP spool file at `date` $spoolfile "
			scp  $spoolfile $sftpconf"/"$sftppath
			log_info "Completed Spooling and SFTP  at `date` " $sqlexec 
		fi

	fi

	log_info "Completed executing SQL file   at `date` " 
	echo " "

done < "$CONTAINER_PATH/$spool_contr_file"
echo " "
read -p "ENTER TO CONTINUE / CONTRL-C TO EXIT " xxx

source spool.sh $ctry_id
