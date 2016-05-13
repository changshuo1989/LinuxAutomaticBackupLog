#######################################################
#This script is used to help initiate the backup server
#######################################################
#!/bin/bash

SETTINGS=./settings
SCRIPT_DIR=/root/script
LOG_DIR=/var/log/backups/
LOG_FILE=push.log

CONFIG_LOG=config_log
CONFIG_LOG_NUM=5

TEMP_INCRONTAB=incron

function copyIncrontab(){
	incrontab -l > ${TEMP_INCRONTAB}
}

function loadIncrontab(){
	incrontab ${TEMP_INCRONTAB}
	rm -rf ${TEMP_INCRONTAB}
}

function removeFromIncrontab(){
	r_name="$1"
	$(which sed) -i "/${r_name}/d" ${TEMP_INCRONTAB}
}

# Ensure we are root
if [ ! "`whoami`" = "root" ]; then
	echo "Error: You must be root to run this script!";
	exit 1;
fi

#Ensure we have settings file
if [ ! -f $SETTINGS ]; then
        echo "Error: settings file not found!"
        exit 1
fi

#read settings file
while read LINE
do
        if [[ $LINE == SCRIPT_DIR* ]]; then
                IFS='=' read -a SCRIPT_DIR_ARRAY <<< "$LINE";
                if [ ${#SCRIPT_DIR_ARRAY[@]} == 2 ]; then
                        SCRIPT_DIR=${SCRIPT_DIR_ARRAY[1]};
			echo $SCRIPT_DIR
                fi
	elif [[ $LINE == LOG_DIR* ]]; then
                IFS='=' read -a LOG_DIR_ARRAY <<< "$LINE";
                if [ ${#LOG_DIR_ARRAY[@]} == 2 ]; then
                        LOG_DIR=${LOG_DIR_ARRAY[1]};
			echo $LOG_DIR
                fi

        elif [[ $LINE == LOG_FILE* ]]; then
                IFS='=' read -a LOG_FILE_ARRAY <<< "$LINE";
                if [ ${#LOG_FILE_ARRAY[@]} == 2 ]; then
                        LOG_FILE=${LOG_FILE_ARRAY[1]};
			echo $LOG_FILE
                fi
        fi
done < $SETTINGS
copyIncrontab
#read config_log under the directory which stores all runtime files
while read LINE
do
	#variables
	name=""

	if [[ ! $LINE == \#* ]]; then
		IFS=' ' read -a CONFIG_ARRAY <<< "$LINE"
		if [ ${#CONFIG_ARRAY[@]} == $CONFIG_LOG_NUM ]; then
			name=${CONFIG_ARRAY[0]}
			removeFromIncrontab "$name"
		fi
	fi

done < ${SCRIPT_DIR}/${CONFIG_LOG}
loadIncrontab

#remove all runtime files and logs
$(which rm) -rf ${SCRIPT_DIR}
$(which rm) ${LOG_DIR}/${LOG_FILE}
