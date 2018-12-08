#!/bin/bash

source /environment.sh

BIN_DIR="$WORKING_DIR/software/build/bin"
EXEC_AS="root"

# make sure that /etc/sudoers is owned by root
chown root:root /etc/sudoers

# If a USER is passed, create one and switch to it
if [[ -z "${USER}" ]]; then
    echo "Running as root."
else
    # parse USER
    IFS=':' read -r -a user_arr <<< "$USER"
    # create new USER
    USERNAME="${user_arr[0]}-docker"
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
    echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/sudo_no_password
    chmod 0440 /etc/sudoers.d/sudo_no_password
    # source env
    echo "source /environment.sh" >> /home/$USERNAME/.bashrc
    chown -R $USERNAME:$USERNAME /home/$USERNAME
    echo "Now running as $USERNAME."
    EXEC_AS="$USERNAME"
fi

echo "-------------------------------------------"

# TODO: this is a "smart bash" block, that runs bash when /build/bin does not exist
#       I'm not sure why this is there. I disable it for now, if we find the reason
#       why this was implemented in the first place we can re-enable it.
#       Though, make sure we can run bot-procman-deputy even though the dir /build/bin
#       does not exist.
#
# If the build/bin directory does not exist, run bash instead
# if [ -d $BIN_DIR ]
# then
#     if [ $# -gt 0 ]; then
#         sudo PYTHONPATH=$PYTHONPATH LD_LIBRARY_PATH=$LD_LIBRARY_PATH -u $EXEC_AS -H -E bash -c "$*"
#     else
#         sudo PYTHONPATH=$PYTHONPATH LD_LIBRARY_PATH=$LD_LIBRARY_PATH -u $EXEC_AS -H -E bash
#     fi
# else
#     echo "${BIN_DIR} not found. Running bash instead."
#     sudo PYTHONPATH=$PYTHONPATH LD_LIBRARY_PATH=$LD_LIBRARY_PATH -u $EXEC_AS -H -E bash
# fi


if [ $# -gt 0 ]; then
    sudo PYTHONPATH=$PYTHONPATH LD_LIBRARY_PATH=$LD_LIBRARY_PATH -u $EXEC_AS -H -E bash -c "$*"
else
    sudo PYTHONPATH=$PYTHONPATH LD_LIBRARY_PATH=$LD_LIBRARY_PATH -u $EXEC_AS -H -E bash
fi
