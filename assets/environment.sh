#!/bin/bash

# source ROS (if ROS is found)
if [ -n "$ROS_DISTRO" ]; then
    source /opt/ros/$ROS_DISTRO/setup.bash
fi

# configure ROS URL
export ROS_MASTER_URI="http://$ROS_MASTER_HOST:11311"

# configure LCM URL
export LCM_DEFAULT_URL="udpm://$LCM_IP:$LCM_PORT?ttl=$LCM_TTL"

# source custom file
if [ -n "$CUSTOM_SETUP_FILE" ]; then
  if [ -f "$CUSTOM_SETUP_FILE" ]; then
    echo "Sourcing custom file '$CUSTOM_SETUP_FILE'..."
    source "$CUSTOM_SETUP_FILE" --extend
  fi
fi

# auto-source third-party script (if any)
if [ -f /code/devel/setup.bash ]; then
    source /code/devel/setup.bash --extend
fi
