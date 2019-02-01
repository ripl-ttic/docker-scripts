#!/bin/bash

# check dependencies
declare -a DEPENDENCIES=("sudo" "chown")

## now loop through the above array
for dep in "${DEPENDENCIES[@]}"
do
   which "$dep" >/dev/null 2>&1
   if [ $? -ne 0 ] ; then
       # the dependency `$dep` is not sarisfied
       echo ""
       echo "FATAL: The command '$dep' is necessary and was not found in your docker container."
       echo "Please, install it before using 'docker-scripts'. Exiting...\n"
       echo ""
       exit
   fi
done

source /environment.sh

EXEC_AS="root"

# make sure that /etc/sudoers is owned by root
chown root:root /etc/sudoers >/dev/null 2>&1

# If a USER is passed, create one and switch to it
if [[ -z "${USER}" ]]; then
    echo "Running as root."
else
    # parse USER
    IFS=':' read -r -a user_arr <<< "$USER"
    USERNAME="${user_arr[0]}-docker"
    # check if the user already exists
    cat /etc/passwd | grep ${USERNAME} >/dev/null 2>&1
    if [ $? -eq 0 ] ; then
        # the user exists
        echo "Running as $USERNAME."
    else
        # the user does not exist, create one
        if [ ${#user_arr[@]} -eq 1 ]
        then
            echo "Creating user $USERNAME..."
            useradd -m "$USERNAME" &> /dev/null
        else
            echo "Creating user $USERNAME with ID #${user_arr[1]}..."
            useradd -m -u "${user_arr[1]}" "$USERNAME" &> /dev/null
        fi
        # add user to dialout group
        usermod -a -G dialout "$USERNAME"
        # let the user run sudo without password
        mkdir -p /etc/sudoers.d
        echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/sudo_no_password
        chmod 0440 /etc/sudoers.d/sudo_no_password
        # source env
        echo "source /environment.sh" >> /home/$USERNAME/.bashrc
        chown -R $USERNAME:$USERNAME /home/$USERNAME
        echo "Now running as $USERNAME."
    fi
    # create new USER
    EXEC_AS="$USERNAME"
fi

echo "-------------------------------------------"

if [ $# -gt 0 ]; then
    sudo PATH=$PATH PYTHONPATH=$PYTHONPATH LD_LIBRARY_PATH=$LD_LIBRARY_PATH -u $EXEC_AS -H -E bash -c "$*"
else
    sudo PATH=$PATH PYTHONPATH=$PYTHONPATH LD_LIBRARY_PATH=$LD_LIBRARY_PATH -u $EXEC_AS -H -E bash
fi
