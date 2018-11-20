#!/bin/bash
##
##  FILE NAME		= install.sh						            ##
##  DESCRIPTION         = This script is used to install tool		    ##
##  AUTHOR		= Kalyan
##  DATE OF CREATION    = 10-05-2014							    ##
##  NOTE		= ##Intall Scripts
##					The actual logic will be in functions
##--**************************************************************************************--##
source functions.sh
no_ctry=0

no_contr=0
no_spool_contr=0

ctry_name=""
orig_mig_path=""
ctry_wise=""
log_path=""
sql_path=""
container_path=""
output_path=""
temp_config=config_ins.env

if  [ -f "$temp_config" ] 
then
	rm $temp_config
fi

print_header
echo " "
echo "Begin Installation...."
echo " "



#declare -A arr_config

while read -r line
do	
#check for comment and blank lines
	if [ -z "$line" ] || [ ${line:0:1} == "#" ] || [ ${line:0:1} == "!" ];
	then
		continue
	fi
	
#Extract the variable name, default value, writeable, description and type
	config_line=$( echo  "$line" | cut -d ":" -f 1 ) 
	isWrite=$( echo  "$line" | cut -d ":" -f 2 ) 
	config_desc=$( echo  "$line" | cut -d ":" -f 3 ) 
	config_type=$( echo  "$line" | cut -d ":" -f 4 ) 


	
	var_name=$( echo  "$config_line" | cut -d "=" -f 1 )
	var_value=$( echo "$config_line" | cut -d "=" -f 2 )
	
	change_var_value=$var_value
	
	echo $var_name"="$var_value
	#If readonly then just show the value and continue	
	if [ "$isWrite" == "R" ]
	then
		echo $config_desc
		read -p "You cannot change this value. Press enter to continue" input </dev/tty	
		echo "$var_name=$change_var_value" >> $temp_config

		continue
	fi
	
	#if Yes no field then input is different
	if [ "$config_type" = "YN" ];
	then
		while true; do
			read -p "$config_desc" yn </dev/tty	    	
			case "$yn" in
				"") change_var_value=$var_value; break;;
				[Yy]) change_var_value="Y"; break;;
				[Nn]) change_var_value="N"; break;;
				*) continue
			esac
		done
	else
		while true; do
			read -p "$config_desc" input </dev/tty	  
			if  [ -z "$input" ]
			then
				break
			else
				change_var_value=$input								
				if [ "$var_name" = "ORIGINAL_MIG_PATH" ] 
				then
					#Check if directory exists
					if [ -d "$change_var_value" ] && [ -w "$change_var_value" ] ; then						
						break						
					else
						echo "Directory Does not Exist or cannot write"
						continue
					fi
				else
					break
				fi
			fi
		done
		
		  	
	fi
#Uncomment if using bash version 4
#	arr_config["$var_name"]=$change_var_value
	if [ "$var_name" = "ORIGINAL_MIG_PATH" ] 
	then
		orig_mig_path="$change_var_value" 
	fi 
	if [ "$var_name" = "NO_CTRY" ] 
	then
		no_ctry=$change_var_value
	fi
	if [ "$var_name" = "COUNTRY_WISE" ] 
	then
		ctry_wise=$change_var_value					
	fi
	if [ "$var_name" = "SQL_PATH" ] 
	then
		sql_path=$change_var_value					
	fi
	if [ "$var_name" = "CONTAINER_PATH" ] 
	then
		container_path=$change_var_value					
	fi
	if [ "$var_name" = "LOG_PATH" ] 
	then
		log_path=$change_var_value					
	fi
	if [ "$var_name" = "OUTPUT_PATH" ] 
	then
		output_path=$change_var_value					
	fi
	echo "$var_name=$change_var_value" >> $temp_config
	echo "  " >> $temp_config
	echo "  " 
	
	
done < config_tmpl.env


#Now get the country details
counter=1

until [ $counter -gt $no_ctry ]
do
	echo "Enter country details for Country No. "$counter
	
	#Enter country 
	while true; do
		read -p "Enter Name of Country>" input
		if  [ -z "$input" ]
		then
			echo "Country cannot be blank..."
			continue
		fi
		break
	done
	ctry_name=$input
	var_name="CTRY_"$counter"_NAME"
	output="$var_name""=""$input"
	echo "$output" >> $temp_config
	echo "  " >> $temp_config
	echo "  " 
	
	while true; do
		read -p "Enter DB Connect>" input
		if  [ -z "$input" ]
		then
			echo "DB Connect cannot be blank..."
			continue
		fi
		break
	done
	var_name="CTRY_"$counter"_DB"
	output="$var_name""=""$input"
	echo "$output" >> $temp_config
	echo "  " >> $temp_config
	echo "  " 
	
	while true; do
		read -p "Enter Number of Container>" input
		if ! [[ "$input" =~ ^[0-9]+$ && "$input" -gt 0 ]]
		then
			echo "Container has to be a number greater than 0..."
			continue
		fi
		break
	done
	no_contr=$input
	var_name="NO_CONTR_FOR_"$counter
	output="$var_name""=""$input"
	echo "$output" >> $temp_config
	echo "  " >> $temp_config
	echo "  " 
	
	while true; do
		read -p "Enter Number of SPOOL Container>" input
		if ! [[ "$input" =~ ^[0-9]+$ && "$input" -gt 0 ]]
		then
			echo "SPOOL Container has to be a number greater than 0..."
			continue
		fi
		break
	done
	no_spool_contr=$input
	var_name="NO_SPOOL_CONTR_FOR_"$counter
	output="$var_name""=""$input"
	echo "$output" >> $temp_config
	echo "  " >> $temp_config
	echo "  " 
	
	#Get the Container Details
	inner_counter=1
	echo "Enter Container details for Country. "$ctry_name
	
	until [ $inner_counter -gt $no_contr ]
	do
		echo "For Country $ctry_name Enter details for Container No. $inner_counter"
		
		while true; do
			read -p "Enter Name of Container>" input
			if  [ -z "$input" ]
			then
				echo "Name of Container cannot be blank..."
				continue
			fi
			break
		done
		var_name="CONTR_"$inner_counter"_NAME_FOR_"$counter
		output="$var_name""=""$input"
		echo "$output" >> $temp_config
		echo "  " 
		
		while true; do
			read -p "Enter File Name of Container>" input
			if  [ -z "$input" ]
			then
				echo "File Name of Container cannot be blank..."
				continue
			fi
			break
		done
		var_name="CONTR_"$inner_counter"_FILE_FOR_"$counter
		output="$var_name""=""$input"
		echo "$output" >> $temp_config
		echo "  " 
		
		echo "  " >> $temp_config

		((inner_counter++))			
	done
	
	#Get the Spool Container
	inner_counter=1
	echo "Enter SPOOL Container details for Country. "$ctry_name
	
	until [ $inner_counter -gt $no_spool_contr ]
	do
		echo "For Country $ctry_name Enter details for SPOOL Container No. $inner_counter"
		
		while true; do
			read -p "Enter Name of SPOOL Container>" input
			if  [ -z "$input" ]
			then
				echo "Name of SPOOL Container cannot be blank..."
				continue
			fi
			break
		done
		var_name="SPOOL_CONTR_"$inner_counter"_NAME_FOR_"$counter
		output="$var_name""=""$input"
		echo "$output" >> $temp_config
		echo "  " 
		
		while true; do
			read -p "Enter File Name of SPOOL Container>" input
			if  [ -z "$input" ]
			then
				echo "File Name of SPOOL Container cannot be blank..."
				continue
			fi
			break
		done
		var_name="SPOOL_CONTR_"$inner_counter"_FILE_FOR_"$counter
		output="$var_name""=""$input"
		echo "$output" >> $temp_config
		echo "  " 
		
		echo "  " >> $temp_config

		((inner_counter++))			
	done

	((counter++))	
	echo "  " 
	echo "  " 
#Create all the directories
	mig_path=$orig_mig_path
	if [ "$ctry_wise" = "Y" ] 
	then
		mig_path="$orig_mig_path/$ctry_name"
	fi
	if ! [ -d "$mig_path" ] 
	then
		mkdir $mig_path	
	fi
#Log path should be on the root of migration folder and not for each country
	if ! [ -d "$orig_mig_path/$log_path" ] 
	then
		mkdir "$orig_mig_path/$log_path"
	fi
	if ! [ -d "$mig_path/$sql_path" ] 
	then
		mkdir "$mig_path/$sql_path"
	fi
	if ! [ -d "$mig_path/$container_path" ] 
	then
		mkdir "$mig_path/$container_path"
	fi
	if ! [ -d "$mig_path/$output_path" ] 
	then
		mkdir "$mig_path/$output_path"
	fi
done


cp ./execute.sh $orig_mig_path
cp ./spool.sh $orig_mig_path
cp ./functions.sh $orig_mig_path
cp ./$temp_config $orig_mig_path/config.env
cp ./LICENSE $orig_mig_path
rm $temp_config


echo "Installation completed"
echo "Go to $orig_mig_path and call execute.sh shell script"
