#!/bin/bash
##
##  FILE NAME		= functions.sh						            ##
##  DESCRIPTION         = This script is used to store common functions 		    ##
##  AUTHOR		= Kumaresan
##  DATE OF CREATION    = 05-06-2014							    ##
##  NOTE		= ##


## Prints header wherever required
function print_header {
	clear
	echo " "
	echo " "
	echo " "
	echo "                  WELCOME TO VERIFICATION REPORT GENERATOR"
	echo " "
	echo "BANK NAME : "$BANK_NAME
	echo "MIGRATION PATH : "$MIG_PATH
 }
 
 #Function for logging information
 function log_all {

	 if [ $LOG_ALL = "Y" ]
	 then
		echo `date` ":"$1 | tee -a $LOG_PATH/$LOG_ALL_FILE
 	 fi
 
 }
 function log_info {

	   
	 txt=$1

	 if [ $LOG_INFO = "Y" ]
	 then
		 echo `date` ":"${txt} | tee -a $LOG_PATH/$LOG_INFO_FILE
	 fi
	 log_all "${txt}"

 
 }
 
 function log_error {
   txt=$1
  if [ $LOG_ERROR = "Y" ]
  then
		 echo `date` ":"$txt | tee -a $LOG_PATH/$LOG_ERROR_FILE
  fi
	 log_all "${txt}"

 
 }
 
  function log_warn {
  
	 txt=$1
 	 if [ $LOG_WARN = "Y" ]
	 then
		 echo `date` ":"$txt | tee -a $LOG_PATH/$LOG_WARN_FILE
	 fi
	 log_all "${txt}"
 
 
 }
 
#if critical values are empty bail out with an error
 function check_critical_var {

	if [ -z "$1" ]
	then
		log_error "Variable  "$2" is empty. Exiting. conf.env needs to be worked on"
		exit
	fi
	 
} 

#if the containers,  sql and output needs to be stored country wise
#COUNTRY_WISE switch needs to be turned on.
# choose country function calls this function
function country_wise {

	 MIG_PATH="$ORIGINAL_MIG_PATH"
	 if [ $COUNTRY_WISE = "Y" ]	
	 then
	 	MIG_PATH="$ORIGINAL_MIG_PATH/$ctry"
	 	
	 fi
#Log path should be outside as we want to create single log paths
	 LOG_PATH=$ORIGINAL_MIG_PATH/$LOG_PATH
	 SQL_PATH=$MIG_PATH/$SQL_PATH
	 CONTAINER_PATH=$MIG_PATH/$CONTAINER_PATH
	 OUTPUT_PATH=$MIG_PATH/$OUTPUT_PATH
	 

}

 #Choose Country
 function choose_country {
	
		print_header
		echo "ACTION : CHOOSE COUNTRY"
		echo " "
		counter=1
		check_critical_var "$NO_CTRY" "NO_CTRY"
		until [ $counter -gt $NO_CTRY ]
		do
			ctry_var="CTRY_"$counter"_NAME"
			check_critical_var "${!ctry_var}" $ctry_var
			echo  "                          "$counter." "${!ctry_var}
			echo " "

			((counter++))
		done
		echo "                          q:ENTER 'Q' FOR QUIT"
		echo " "
		read -p "                          ENTER THE CHOICE : " choice
		case $choice in
		[qQ])
			log_info "Quit From Country Menu "

			clear
			exit
			;; 	
		*)
			if ! [[ "$choice" =~ ^[0-9]+$ && "$choice" -le $NO_CTRY ]]
			then
				choose_country
			else
			
				dbconf_var="CTRY_"$choice"_DB"
				check_critical_var "${!dbconf_var}" $dbconf_var

				dbconf=${!dbconf_var}
				ctry_var="CTRY_"$choice"_NAME"
				ctry=${!ctry_var}
				ctry_id=$choice
				country_wise
				log_info "Selected the country $ctry"
			fi
		esac
}	



 #Choose Registered Containers
 function choose_registered_containers {
	
		print_header
		echo " "
		echo "**************************************** COUNTRY : $ctry ****************************************"
		echo " "
		echo "DATABASE : "$dbconf
		echo "ACTION : CHOOSE CONTAINER"
		echo " "
		counter=1
		no_contr_var="NO_CONTR_FOR_"$ctry_id
		no_contr=${!no_contr_var} 
		check_critical_var "$no_contr" $no_contr_var
		
		
		until [ $counter -gt $no_contr ]
		do

			contr_var="CONTR_"$counter"_NAME_FOR_"$ctry_id
			contr=${!contr_var}
			check_critical_var "$contr" $contr_var

			echo  "                          "$counter." "$contr
			echo " "

			((counter++))
		done
		echo "                          A:ENTER 'A' FOR AD HOC CONTAINER"
		echo " "
		
		echo "                          C:ENTER 'C' FOR COUNTRY MENU"
		echo " "
		echo "                          Q:ENTER 'Q' FOR QUIT"
		echo " "
		echo " "
		read -p "                          ENTER THE CHOICE : " choice
		case $choice in
		[qQ])

			log_info "Quit From Container Menu "
			
			clear
			exit
			;; 	
		[cC])
			log_info "Going back to the Country Menu"

			source $MAIN_SHELL
			
			exit
			;;
		[aA])
			log_info "Selected AD HOC Container"
			contr_name="AD HOC Container"
			contr_file=$ADHOC_CONTAINER
			
			;;
		*)
			if ! [[ "$choice" =~ ^[0-9]+$ && "$choice" -le $no_contr ]]
			then
				choose_registered_containers
			else
				contr_name_var="CONTR_"$choice"_NAME_FOR_"$ctry_id
				contr_file_var="CONTR_"$choice"_FILE_FOR_"$ctry_id

				contr_name=${!contr_name_var}
				contr_file=${!contr_file_var}
				check_critical_var "$contr_file" "$contr_file_var"
				log_info "Selected the Container $contr_name"
			fi

			
			
		esac
}	




#Choose Registered Containers
 function choose_registered_spool_containers {
	
		print_header
		echo " "
		echo "**************************************** COUNTRY : $ctry ****************************************"
		echo " "
		echo "DATABASE : "$dbconf
		echo "ACTION : CHOOSE SPOOL CONTAINER"
		echo " "
		counter=1
		no_spool_contr_var="NO_SPOOL_CONTR_FOR_"$ctry_id
		no_spool_contr=${!no_spool_contr_var} 
		check_critical_var "$no_spool_contr" $no_spool_contr_var
		
		
		until [ $counter -gt $no_spool_contr ]
		do

			spool_contr_var="SPOOL_CONTR_"$counter"_NAME_FOR_"$ctry_id
			spool_contr=${!spool_contr_var}
			check_critical_var "$spool_contr" $spool_contr_var

			echo  "                          "$counter." "$spool_contr
			echo " "

			((counter++))
		done
		echo "                          A:ENTER 'A' FOR AD HOC SPOOL CONTAINER"
		echo " "
		
		echo " "
		echo "                          Q:ENTER 'Q' FOR QUIT"
		echo " "
		echo " "
		read -p "                          ENTER THE CHOICE : " choice
		case $choice in
		[qQ])

			log_info "Quit From Container Menu "
			
			clear
			exit
			;; 	
		[aA])
			log_info "Selected AD HOC SPOOL Container"
			spool_contr_name="AD HOC SPOOL Container"
			spool_contr_file=$ADHOC_CONTAINER
			
			;;
		*)
			if ! [[ "$choice" =~ ^[0-9]+$ && "$choice" -le $no_spool_contr ]]
			then
				choose_registered_spool_containers
			else
				spool_contr_name_var="SPOOL_CONTR_"$choice"_NAME_FOR_"$ctry_id
				spool_contr_file_var="SPOOL_CONTR_"$choice"_FILE_FOR_"$ctry_id

				spool_contr_name=${!spool_contr_name_var}
				spool_contr_file=${!spool_contr_file_var}
				check_critical_var "$spool_contr_file" "$spool_contr_file_var"
				log_info "Selected the SPOOL Container $spool_contr_name"
			fi

			
			
		esac
}	