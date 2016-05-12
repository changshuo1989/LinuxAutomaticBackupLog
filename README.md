========================================================
USAGE
========================================================

This script is used to run on the backup server side to receive updated log and send log metrics to database through curl request


========================================================
CONFIGURATION
========================================================
Note:
1. No space allowed for every variables

config_log file:
1. name: the name you defined like database, git, filesystem
2. log_dir: the directory the log file stored, and the incron monitored
3. log_file_name: the file name under this directory

========================================================
RERUN THIS SCRIPT
========================================================
1. check incrontab(incrontab -e)
2. check /root/script dir
