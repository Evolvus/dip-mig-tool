#!/bin/bash
##
##  FILE NAME		= execute.sh						            ##
##  DESCRIPTION         = This script is used to execute sql 		    ##
##  AUTHOR		= Alavudeen
##  DATE OF CREATION    = 01-06-2014							    ##
##  NOTE		= ##This is the main program that drives this tool. The flow is defined here
##					The actual logic will be in functions
##--**************************************************************************************--##

#Installation Bit
if [ $1 = "INSTALL" ]
then
	if  [ -f "install.sh" ] 
	then
		source install.sh
	else
		echo "File install.sh  does not exist. Please check"
	fi
	
	exit
fi

if [ $1 = "GETCODE" ]
then
	if  [ -f "getcode.sh" ] 
	then
		source getcode.sh
	else
		echo "File getcode.sh  does not exist. Please check"
	fi
	
	exit
fi

if [ $1 = "SPOOL" ]
then
	if  [ -f "spool.sh" ] 
	then
		source spool.sh
	else
		echo "File spool.sh  does not exist. Please check"
	fi
	
	exit
fi

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
contr=""
#holds the filename of the container
contr_file=""

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


		


echo "ACTION : CHOOSE CONTAINER"

choose_registered_containers

log_info "Executing SQLs from Container $contr_name with file $contr_file"

echo " "
cat "$CONTAINER_PATH/$contr_file" 2> $LOG_PATH/$LOG_ERROR_FILE 

echo " "
read -p "ENTER TO CONTINUE / CONTRL-C TO EXIT " xxx
#LOOP THROUGH EACH LINE OF CONTAINER FILE AND EXECUTE THE SQL FILE
while read -r line
do

    name=$line
	f1=${line:0:1}
	if [ "$f1" == "#" ] || [ "$f1" == "" ]; then

		continue
	fi
	name="$SQL_PATH/$name"
	#Removes control M characters, nul characters and blank lines
	perl -pi -e 's/\r//g' $name
	perl -pi -e 's/\000//g' $name
	perl  -i -n -e'print if /\S/' $name

	log_info "Executing SQL file   at `date`  $name"

	sqlplus -s $dbconf/$DB_PASS @$name </dev/null
#	sleep  $[RANDOM%5+1]
	echo " "

	log_info "Completed executing SQL file   at `date` " 
	echo " "

done < "$CONTAINER_PATH/$contr_file"
echo " "
read -p "ENTER TO CONTINUE / CONTRL-C TO EXIT " xxx

source $MAIN_SHELL $ctry_id
