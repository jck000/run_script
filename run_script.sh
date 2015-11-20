#!/bin/sh 

#
# Description:
#    This is a generic script used to run other scripts with specific environment/configuration also it enforces that 
#    only a single copy of the running script runs at one time.
#
# Usage: 
#    run_script.sh 
#

#
# Set up default environment variables
#
umask 000

MYHOSTNAME=`hostname|sed 's/\..*$//'`

display_w_timestamp() {
  disptime="`date +'%Y-%m-%d %H:%M:%S'`"

  echo "$disptime $1"

}

#
# Help and usage information.
#
usage() {
  echo "

Usage:

  run_script.sh [OPTIONS]

    --exec=<script>        - script to execute.  Include full path.

    --conf=<config>        - configuration file.  Include full path.

    --args="arg1 arg2 ..." - arguments to pass to script

    --env:var="val"        - Set environment variables

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
    run_script_conf      - Default configuration file

    This script is designed to be used to setup an environment and run a script or application with that environment.  
    Also, it's designed to avoid access to system infrustructure in order to avoid permission issues.  In other words, 
    you can use it without having admin access.  Place this script into /usr/local/bin or $HOME/bin along with 
    run_script_functions and run_script_conf.  Additionally, you may have multiple config files and specify a different 
    one for each application.  You don't need to hack this script to take care of that.
    
    Look at the directory structure below:

      /home/username
                    /bin         <-- personal version of run_script.sh
                    /app1
                         /conf   <-- application specific configuration file(s)
                         /locks  <-- application lock file location
                    /app2
                         /conf
                         /locks

    Lock files are script.lck and contains the process id.

    Required variables:


  "|less
  exit

}


# Load funtions
if [ -f $HOME/bin/run_script_functions ] ; then
  . $HOME/bin/run_script_functions
elif [ -f /usr/local/bin/run_script_functions ] ; then
  . /usr/local/bin/run_script_functions
else 
  display_w_timestamp "Functions file does not exist in /usr/local/bin or $HOME/bin"
  help
fi


# Load config
if [ -f $HOME/bin/run_script_conf ] ; then
  . $HOME/bin/run_script_conf
elif [ -f /usr/local/bin/run_script_conf ] ; then
  . /usr/local/bin/run_script_conf
else 
  display_w_timestamp "Config file does not exist in /usr/local/bin or $HOME/bin"
  help
fi


# If this is not a terminal, redirect output.  Assuming CRON job.
if [ ! -t 0 ] ; then
  exec >> "$LOGDIR/runlog.$TODAY"
  exec 2>&1
fi



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
      if [ -f $CONF ] ; then
        display_w_timestamp "EXECUTABLE SCRIPT is $EXEC "
      else
        display_w_timestamp "EXECUTABLE SCRIPT $EXEC does not exist or is not executable "
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
    --func=*)
      FUNC=`echo $1|cut -d'=' -f2 `; export FUNC
      if [ -x $FUNC ] ; then
        . $FUNC
        display_w_timestamp "CUSTOM FUNCTIONS FILE is $FUNC "
      else
        display_w_timestamp "CUSTOM FUNCTIONS FILE $FUNC does not exist or is not readable "
        usage
      fi
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
      display_w_timestamp "ERROR $1 is not an acceptable argument "
      error 2 $1
      exit
    ;;
  esac
  shift
done

#
# Run it!
#

display_w_timestamp "START $EXEC $ARGS"
do_run_script $EXEC $ARGS   ### Run it!
display_w_timestamp "START $EXEC $ARGS"


