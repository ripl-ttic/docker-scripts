#! /bin/bash

# define constants
QUIET=0
DOCKER_SCRIPTS_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
PROJECT_HOME=$DOCKER_SCRIPTS_DIR/..

# define default values
ROS_MASTER_HOST='localhost'
MACHINE_ROLE='default'

# parse arguments
CUR=0
while [ $CUR -lt $# ]; do
  CUR="$(($CUR+1))"
  arg=${!CUR}
  case $arg in
    --quiet)
    QUIET=1
    break
    ;;
  esac
done

# load project settings file if it exists
if [ ! -f $PROJECT_HOME/project.settings ]; then
  echo "FATAL: File 'project.settings' not found in the main directory of your project ($PROJECT_HOME)."
  echo "Create one before launching this script. A template is available in '$DOCKER_SCRIPTS_DIR/project.settings.template'. Exiting..."
  exit 2
fi
source $PROJECT_HOME/project.settings

# look for the PROJECT_NAME variable
if [ -z "$PROJECT_NAME" ]; then
  echo "FATAL: The variable 'PROJECT_NAME' is not set. Make sure it is defined in your 'project.settings' file."
  echo "Exiting..."
  exit 3
fi

# look for the DOCKER_IMAGE variable
if [ -z "$DOCKER_IMAGE" ]; then
  echo "FATAL: The variable 'DOCKER_IMAGE' is not set. Make sure it is defined in your 'project.settings' file."
  echo "Exiting..."
  exit 4
fi

# load machine settings file if it exists
if [ ! -f $PROJECT_HOME/machine.settings ]; then
  echo "WARNING: File 'machine.settings' not found in the main directory of your project."
  echo "Default values for ROS_MASTER_HOST and MACHINE_ROLE will be used!"
else
  source $PROJECT_HOME/machine.settings
fi

# print out info about the project
if [ $QUIET -eq 0 ]; then
  echo ""
  echo "Project: $PROJECT_NAME"
  echo "  - Role: $MACHINE_ROLE"
  echo ""
fi
