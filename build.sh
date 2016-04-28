#!/bin/bash
#this script is used to initial the incron job

SCRIPT_DIR=/root/script/
CONFIG_LOG=./config_log
LOG_INFO=info.sh
TEMP_INCRONTAB=incron
CONFIG_LOG_NUM=3



function copyIncrontab(){
	incrontab -l > ${TEMP_INCRONTAB}
}

function copyScript(){
	$(which mkdir) -p $SCRIPT_DIR 
	$(which cp) $LOG_INFO $SCRIPT_DIR
}

function addIntoIncrontab(){
	c_name="$1"
	c_dir="$2"
	c_file="$3"
	t_dir='$@'
	t_file='$#'
	command="${c_dir} IN_MODIFY $(which bash) ${SCRIPT_DIR}${LOG_INFO} ${c_name} ${c_dir} ${c_file} ${t_dir} ${t_file}"
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


copyIncrontab
copyScript
while read LINE
do
	#variable
	name=""
	file=""
	
	if [[ ! $LINE == \#* ]]; then 
		IFS=' ' read -a CONFIG_ARRAY <<< "$LINE"
		if [ ${#CONFIG_ARRAY[@]} == $CONFIG_LOG_NUM ]; then

			name=${CONFIG_ARRAY[0]}
			#echo $name
			dir=${CONFIG_ARRAY[1]}
			#echo $file
			file=${CONFIG_ARRAY[2]}
			addIntoIncrontab "$name" "$dir" "$file"
		fi

	fi
done < $CONFIG_LOG
loadIncrontab
