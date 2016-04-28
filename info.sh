#!/bin/bash
#This script will be triggered by incron and is used to parse the log file and send backup monitroing information to database
NAME=$1
DIR=$2
FILE=$3
TRIGGER_DIR=$4
TRIGGER_FILE=$5

START_TIME=""
END_TIME=""
ELAPSED_TIME=""
ERRORS=""
INTERVAL=""


START_TIME_LINE_NUM=7
END_TIME_LINE_NUM=7
ELAPSED_TIME_LINE_NUM=4
ERRORS_LINE_NUM=2
INTERVAL_LINE_NUM=2


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
				echo $START_TIME >> /root/file
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
				echo $END_TIME >> /root/file
			fi
		
		elif [[ $LINE == ElapsedTime* ]]; then
			IFS=' ' read -a LINE_ARRAY <<< "$LINE"
			if [ ${#LINE_ARRAY[@]} == $ELAPSED_TIME_LINE_NUM ]; then
			
				elapsed_time=${LINE_ARRAY[2]:1}
				elapsed_unit=${LINE_ARRAY[3]}
				loeu=${#elapsed_unit}
				elapsed_unit=${elapsed_unit:0:loeu-1}
				ELAPSED_TIME="$elapsed_time $elapsed_unit"
				#test
				echo $ELAPSED_TIME >> /root/file
			fi
		elif [[ $LINE == Errors* ]]; then
			IFS=' ' read -a LINE_ARRAY <<< "$LINE"
			if [ ${#LINE_ARRAY[@]} == $ERRORS_LINE_NUM ]; then
				ERRORS=${LINE_ARRAY[1]}
				#test
				echo $ERRORS >> /root/file
			fi

		elif [[ $LINE == Interval* ]]; then
			IFS=' ' read -a LINE_ARRAY <<< "$LINE"
			if [ ${#LINE_ARRAY[@]} == $INTERVAL_LINE_NUM ]; then
			
				INTERVAL=${LINE_ARRAY[1]}
				#test
				echo $INTERVAL >> /root/file
			fi				
		fi		
	done < ${TRIGGER_DIR}/${TRIGGER_FILE}
	if [ "$START_TIME" != "" ] && [ "$END_TIME" != "" ] && [ "$ELAPSED_TIME" != "" ] && [ "$ERRORS" != "" ]; then
		#send curl request
		:
	fi

else 
	:	
fi


