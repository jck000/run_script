# RUN SCRIPT


## Description:
    This is a generic script used to run other scripts with specific environment/configuration also it 
    enforces that only a single copy of the running script runs at one time.

## Installation
    Copy run_script.sh and run_script_functions to /usr/local/bin

## Usage:

  run_script.sh [OPTIONS]

    --exec=<script>        - script to execute.  Include full path and all arguments.

    --conf=<config>        - configuration file.  Include full path.

    --env:var="val"        - Set environment variables.  Use this to override some variables from the config file

    --nolock               - Default is to place a lock.  -nolock will NOT place a lock so that
                             You can run multiple instances of this script.

    --DEBUG                - Run in debug mode

    --h|--help             - Detailed help.

    --usage                - This screen

    
  run_script.sh [OPTIONS]

    There are 3 parts to this script.  They should all be placed into /usr/local/bin or $HOME/bin.  Make sure 
    that the location is part of your path.

    run_script.sh          - Main script.
    run_script_functions   - Functions used by the main script
    run_script_sample.conf - A sample application configuration file

    This script is designed to be used to setup an environment and run a script or application with that 
    environment.  Also, it's designed to avoid access to system infrustructure so that it avoids permission 
    issues.  In other words, you can use it without having admin access.  Place run_script.sh into 
    /usr/local/bin along with run_script_functions.  Additionally, you may have multiple config files and 
    specify a different one for each application.  
    
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
      LOCKDIR
      LOGDIR

