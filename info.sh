#!/bin/bash
#This script will be triggered by incron and is used to parse the log file and send backup monitroing information to database
NAME=$1
DIR=$2
FILE=$3
DESTINATION=$4
LOCAL_FOLDER=$5
CONFIG_SERVERS=$6
SUB_SCRIPT=$7
LOG_DIR=$8
LOG_FILE=$9
TRIGGER_DIR=${10}
TRIGGER_FILE=${11}

START_TIME=""
END_TIME=""
ELAPSED_TIME=""
ERRORS=""
INTERVAL="0"

START_TIME_LINE_NUM=7
END_TIME_LINE_NUM=7
ELAPSED_TIME_LINE_NUM=2
ERRORS_LINE_NUM=2
INTERVAL_LINE_NUM=2

CONFIG_SERVERS_NUM=5


#echo -e "${DIR}\n${FILE}\n${TRIGGER_DIR}\n${TRIGGER_FILE}" >> /root/file
if [ "`$(which diff) ${DIR}/${FILE} ${TRIGGER_DIR}/${TRIGGER_FILE}`" = "" ] && [ "$FILE" == "$TRIGGER_FILE" ]; then
	while read LINE
	do
		#echo $LINE >> /root/file
		#parse metrics
		#echo $TRIGGER_FILE >> /root/file

		if [[ $LINE == StartTime* ]]; then
			IFS=' ' read -a LINE_ARRAY <<< "$LINE"
			if [ ${#LINE_ARRAY[@]} == $START_TIME_LINE_NUM ]; then
				sdow=${LINE_ARRAY[2]:1}
				sm=${LINE_ARRAY[3]}
				sdom=${LINE_ARRAY[4]}
				st=${LINE_ARRAY[5]}
				sy=${LINE_ARRAY[6]}
				losy=${#sy}
				sy=${sy:0:losy-1}
				START_TIME="$sdow $sm $sdom $st $sy"
				#test
				#echo $START_TIME >> /root/file
			fi
		elif [[ $LINE == EndTime* ]]; then
			IFS=' ' read -a LINE_ARRAY <<< "$LINE"
			if [ ${#LINE_ARRAY[@]} == $END_TIME_LINE_NUM ]; then
				edow=${LINE_ARRAY[2]:1}
                                em=${LINE_ARRAY[3]}
                                edom=${LINE_ARRAY[4]}
                                et=${LINE_ARRAY[5]}
                                ey=${LINE_ARRAY[6]}
                                loey=${#ey}
                                ey=${ey:0:loey-1}
                                END_TIME="$edow $em $edom $et $ey"
				#test
				#echo $END_TIME >> /root/file
			fi
		
		elif [[ $LINE == ElapsedTime* ]]; then
			IFS='(' read -a LINE_ARRAY <<< "$LINE"
			if [ ${#LINE_ARRAY[@]} == $ELAPSED_TIME_LINE_NUM ]; then			
				elapsed_time=${LINE_ARRAY[1]}
				loet=${#elapsed_time}
				elapsed_time=${elapsed_time:0:loet-1}
				ELAPSED_TIME="$elapsed_time"
				#test
				#echo $ELAPSED_TIME >> /root/file
			fi
		elif [[ $LINE == Errors* ]]; then
			IFS=' ' read -a LINE_ARRAY <<< "$LINE"
			if [ ${#LINE_ARRAY[@]} == $ERRORS_LINE_NUM ]; then
				ERRORS=${LINE_ARRAY[1]}
				#test
				#echo $ERRORS >> /root/file
			fi

		elif [[ $LINE == Interval* ]]; then
			IFS=' ' read -a LINE_ARRAY <<< "$LINE"
			if [ ${#LINE_ARRAY[@]} == $INTERVAL_LINE_NUM ]; then
			
				INTERVAL=${LINE_ARRAY[1]}
				#test
				#echo $INTERVAL >> /root/file
			fi				
		fi		
	done < ${TRIGGER_DIR}/${TRIGGER_FILE}

	if [ "$NAME" != "" ] && [ "$START_TIME" != "" ] && [ "$END_TIME" != "" ] && [ "$ELAPSED_TIME" != "" ] && [ "$ERRORS" != "" ]; then
		
		#copy file to backup node
                #if [ "$REMOTE_HOST" != '*' ]; then
                #       if [ "$REMOTE_PORT" != '*' ]; then
                #                $(which scp) -r -P ${REMOTE_PORT} ${LOCAL_FOLDER} ${REMOTE_HOST}:${REMOTE_FOLDER}
                #        else
                #                $(which scp) -r ${LOCAL_FOLDER} ${REMOTE_HOST}:${REMOTE_FOLDER}
                #        fi
                
                #fi		


		if [ "$DESTINATION" != '*' ]; then
			#send curl request
			$(which curl) -k --data "request=addbackuphistory&type=${NAME}&starttime=${START_TIME}&endtime=${END_TIME}&elapsedtime=${ELAPSED_TIME}&errors=${ERRORS}&interval=${INTERVAL}" ${DESTINATION}
		fi
		#create sub-processes to push files and send curl request

		if [ -e "$CONFIG_SERVERS" ]; then
			#parse config_servers file
			while read LINE
			do
				#variables
				server_name=""
				server_host=""
				server_port=""
				server_password=""
				server_folder=""
			
				if [[ ! $LINE == \#* ]]; then
					#read variables from config file
					IFS=' ' read -a CONFIG_ARRAY <<< "$LINE";
					if [ ${#CONFIG_ARRAY[@]} == $CONFIG_SERVERS_NUM ]; then
						server_name=${CONFIG_ARRAY[0]};
						server_host=${CONFIG_ARRAY[1]};
						server_port=${CONFIG_ARRAY[2]};
						server_password=${CONFIG_ARRAY[3]};
						server_folder=${CONFIG_ARRAY[4]};
						#create sub process
						$(which bash) "$SUB_SCRIPT" "$NAME" "$server_name" "$server_host" "$server_port" "$server_password" "$server_folder" "$LOCAL_FOLDER" "$ERRORS" "$INTERVAL" "$DESTINATION" >> ${LOG_DIR}${LOG_FILE} 2>&1
					fi
				
				fi		
			done < $CONFIG_SERVERS

		fi
	fi

else 
	:	
fi

