#!/bin/sh 

#
# Author: Jack Bilemjian jck000@gmail.com
#
# Description:
#    This is a generic script used to run other scripts with specific environment/configuration also it 
#    enforces that only a single copy of the running script runs at one time.
#
# Usage: 
#    run_script.sh 
#

#
# Set up default environment variables
#

. /usr/local/bin/run_script_functions

HOSTNAME=`hostname|sed 's/\..*$//'`

#
# Help and usage information.
#
usage() {
  echo "

Usage:

  run_script.sh [OPTIONS]

    --exec=<script>        - script to execute.  Include full path and all arguments.

    --conf=<config>        - configuration file.  Include full path.

    --env:var="val"        - Set environment variables.  Use this to override some variables from the config file

    --nolock               - Default is to place a lock.  -nolock will NOT place a lock so that
                             You can run multiple instances of this script.

    --DEBUG                - Run in debug mode

    --h|--help             - Detailed help.

    --usage                - This screen

  "|less
  exit
}

help() {
  echo " 

Help:
    
  run_script.sh [OPTIONS]

    There are 3 scripts that make up this script.  They should all be placed into /usr/local/bin or $HOME/bin.

    run_script.sh        - This script.
    run_script_functions - Functions used by this script
    application.conf     - Application configuration

    This script is designed to be used to setup an environment and run a script or application with that 
    environment.  Also, it's designed to avoid access to system infrustructure so that it avoids permission 
    issues.  In other words, you can use it without having admin access.  Place this script into /usr/local/bin 
    along with run_script_functions.  Additionally, you may have multiple config files and specify a different 
    one for each application.  You don't need to hack this script to take care of that.
    
    Look at the directory structure below:

      /usr/local/bin         <-- location of run_script.sh and run_script_functions
      /home/user/app1/conf   <-- application specific configuration file(s)
                     /locks  <-- application lock file location
                     /logs   <-- application log file location
      /data/app2/conf        <-- these could be anywhere
                /locks
                /logs   

    Lock files are script.lck and contains the process id.

    Required variables:
      APPTMP
      LOGDIR

  "|less
  exit

}



#
# Process arguments
#

while [ $# -ne 0 ] ; do  ### Loop until no more values on the command line
  case "$1" in           ### Process each argument
    --h|-h|--help)
      usage
    ;;
    --exec=*)            ### Script to execute incudes full path
      EXEC=`echo $1|cut -d'=' -f2 `; export EXEC
      SCRIPT=`echo $1|cut -d'=' -f2 |cut -d' ' -f1`; export SCRIPT

      APPNAME=`basename $SCRIPT`;export APPNAME
      APPDIR=`dirname $SCRIPT`;export APPDIR

      if [ -x "$SCRIPT" ] ; then
        display_w_timestamp "EXECUTABLE SCRIPT is $SCRIPT "
      else
        display_w_timestamp "EXECUTABLE SCRIPT $SCRIPT does not exist or is not executable "
        usage
      fi
    ;;
    --conf=*)            ### Configuration file incudes full path
      CONF=`echo $1|cut -d'=' -f2 `; export CONF
      if [ -f $CONF ] ; then
        . $CONF
        display_w_timestamp "CONFIGURATION FILE is $CONF "
      else
        display_w_timestamp "CONFIGURATION FILE $CONF does not exist or is not readable "
        usage
      fi
    ;;
    --args=*)
      ARGS=`echo $1|sed 's/^--args=//'`; export ARGS
    ;;
    --env:*)
      SETIT="`echo $1|cut -d':' -f2`"
      VARNAME="`echo $SETIT|cut -d'=' -f1`"
      VARVAL="`echo $SETIT|cut -d'=' -f2`"
      eval "$VARNAME=$VARVAL"
      display_w_timestamp "set $VARNAME=$VARVAL  "
    ;;
    --nolock)
      LOCK="N"
    ;;
    --DEBUG)
      DEBUG="Y"
      display_w_timestamp "DEBUG is ON "
    ;;
    --usage)
      usage
    ;;
    *)
      display_w_timestamp "ERROR $1 is not an acceptable argument 

"
      error 2 $1
      exit
    ;;
  esac
  shift
done

#
# Load config
#
if [ -z "$CONF" ] ; then
  display_w_timestamp "Config file is not specified

"
  help
fi

#
# Application tmp directory
#
if [ -z "$APPTMP" ] ; then
  display_w_timestamp "APPTMP is not specified

"
  help
fi

#
# Is there a log directory
#
if [ -n "$LOCK" -a -z "$LOGDIR" ] ; then
  display_w_timestamp "LOGDIR is not specified

"
  help
fi

#
# If this is not a terminal, redirect output.  Assuming CRON job.
#
if [ ! -t 0 ] ; then
  exec >> "$LOGDIR/runlog.$TODAY"
  exec 2>&1
fi

#
# Run it!
#

display_w_timestamp "START $SCRIPT "
do_run_script $EXEC ### Run it!
display_w_timestamp "END $SCRIPT"

exit 0


