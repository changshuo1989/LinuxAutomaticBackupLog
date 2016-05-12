NAME=$1
SERVER_NAME=$2
SERVER_HOST=$3
SERVER_PORT=$4
SERVER_PASSWORD=$5
SERVER_FOLDER=$6
LOCAL_FOLDER=$7
ERRORS=$8
INTERVAL=$9
DES=$10

SECONDS=0

#validate variable
if [ "$SERVER_PORT" == '*' ]; then
	$SERVER_PORT="22"
fi

if [ "$SERVER_PASSWORD" == '*' ]; then
	$SERVER_PASSWORD=""
fi 

#push files
startTime=$(date "+%a %b %d %T %Y")
$(which sshpass) -p ${SERVER_PASSWORD} $(which scp) -r -P ${SERVER_PORT} ${LOCAL_FOLDER} ${SERVER_HOST}:${SERVER_FOLDER}
endTime=$(date "+%a %b %d %T %Y")
duration=$SECONDS
elapsed_time="$(($duration / 60)) minutes and $(($duration % 60)) seconds"
#send curl request
NAME="${NAME}(${SERVER_NAME})"
$(which curl) -k --data "request=addbackuphistory&type=${NAME}&starttime=${startTime}&endtime=${endTime}&elapsedtime=${elapsed_time}&errors=${ERRORS}&interval=${INTERVAL}" ${DES}
