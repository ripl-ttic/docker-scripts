#!/bin/bash

# source ROS
source /opt/ros/$ROS_DISTRO/setup.bash

# configure ROS URL
export ROS_MASTER_URI="http://$ROS_MASTER_HOST:11311"

# configure LCM URL
export LCM_DEFAULT_URL="udpm://$LCM_IP:$LCM_PORT?ttl=$LCM_TTL"

# auto-source third-party script (if any)
if [ -f /code/devel/setup.bash ]; then
    source /code/devel/setup.bash --extend
fi
