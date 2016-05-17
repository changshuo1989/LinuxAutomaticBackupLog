#!/bin/bash
#this script is used to initial the incron job


SETTINGS=./settings
SCRIPT_DIR=/root/script/
CONFIG_LOG=./config_log
LOG_INFO=info.sh
PUSH_INFO=push.sh
CONFIG_SERVERS=config_servers
TEMP_INCRONTAB=incron
CONFIG_LOG_NUM=5

LOG_DIR=/var/log/backups/
LOG_FILE=push.log

function copyIncrontab(){
	incrontab -l > ${TEMP_INCRONTAB}
}

function copyScript(){
	$(which mkdir) -p $SCRIPT_DIR 
	$(which cp) $LOG_INFO $SCRIPT_DIR
	$(which cp) $PUSH_INFO $SCRIPT_DIR
	$(which cp) $CONFIG_SERVERS $SCRIPT_DIR
	$(which cp) $CONFIG_LOG $SCRIPT_DIR
}

function addIntoIncrontab(){
	c_name="$1"
	c_dir="$2"
	c_file="$3"
	c_destination="$4"
	c_local_folder="$5"
	t_dir='$@'
	t_file='$#'
	command="${c_dir} IN_CLOSE_WRITE $(which bash) ${SCRIPT_DIR}/${LOG_INFO} ${c_name} ${c_dir} ${c_file} ${c_destination} ${c_local_folder} ${SCRIPT_DIR}/${CONFIG_SERVERS} ${SCRIPT_DIR}/${PUSH_INFO} ${LOG_DIR} ${LOG_FILE} ${t_dir} ${t_file}"
	echo "${command}" >> ${TEMP_INCRONTAB}
}
function loadIncrontab(){
	incrontab ${TEMP_INCRONTAB}
	rm -rf ${TEMP_INCRONTAB}
}


# Ensure we are root

if [ ! "`whoami`" = "root" ]; then


	echo "Error: You must be root to run this script!";


	exit 1;


fi

#Ensure we have incrontab

if [ "`which incrontab`" = "" ]; then

	echo "Error: You have to install incron to run this script!"

	exit 1;

fi

#Ensure we have settings file
if [ ! -f $SETTINGS ]; then
	echo "Error: settings file not found!"
	exit 1
fi

#check curl
if [ "`which curl`" = "" ]; then
	echo "Warning: No curl tool found, you might need this tool to send curl requests!"
	read -p "Are you sure you want to ignore this warning and contine? [Y/N]" USER_RESPONSE
	if echo $USER_RESPONSE | grep -iq Y; then
		:
	else
		exit 1
	fi
	
fi

#check sshpass
if [ "`which sshpass`" = "" ]; then
	echo "Warning: No sshpass found, you might need this tool to push files!"
	read -p "Are you sure you want to ignore this warning and contine? [Y/N]" USER_RESPONSE
	if echo $USER_RESPONSE | grep -iq Y; then
		:
	else
		exit 1
	fi
fi





#read setting variables from settings file
while read LINE
do
	if [[ $LINE == SCRIPT_DIR* ]]; then
		IFS='=' read -a SCRIPT_DIR_ARRAY <<< "$LINE";
		if [ ${#SCRIPT_DIR_ARRAY[@]} == 2 ]; then
			SCRIPT_DIR=${SCRIPT_DIR_ARRAY[1]};
		fi

	elif [[ $LINE == LOG_DIR* ]]; then
		IFS='=' read -a LOG_DIR_ARRAY <<< "$LINE";
		if [ ${#LOG_DIR_ARRAY[@]} == 2 ]; then
			LOG_DIR=${LOG_DIR_ARRAY[1]};
		fi

	elif [[ $LINE == LOG_FILE* ]]; then
		IFS='=' read -a LOG_FILE_ARRAY <<< "$LINE";
		if [ ${#LOG_FILE_ARRAY[@]} == 2 ]; then		
			LOG_FILE=${LOG_FILE_ARRAY[1]};
		fi
	fi
	

done < $SETTINGS 




#create log file
$(which mkdir) -p ${LOG_DIR}
$(which touch) ${LOG_DIR}/${LOG_FILE}


copyIncrontab
copyScript
while read LINE
do
	#variable
	name=""
	dir=""
	file=""
	destination="*"
	local_folder=""
	
	if [[ ! $LINE == \#* ]]; then 
		IFS=' ' read -a CONFIG_ARRAY <<< "$LINE"
		if [ ${#CONFIG_ARRAY[@]} == $CONFIG_LOG_NUM ]; then

			name=${CONFIG_ARRAY[0]}
			#echo $name
			dir=${CONFIG_ARRAY[1]}
			#echo $file
			file=${CONFIG_ARRAY[2]}
			#destination
			destination=${CONFIG_ARRAY[3]}
			#local_folder
			local_folder=${CONFIG_ARRAY[4]}
			addIntoIncrontab "$name" "$dir" "$file" "$destination" "$local_folder"
		fi

	fi
done < $CONFIG_LOG
loadIncrontab
