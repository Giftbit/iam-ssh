#!/bin/bash

# This script gets the list of authorized users, and ensures that there is a 
# local user for each authorized user. If a local user does not exist, then 
# the SSH Server will reject the request before calling any of our scripts.
#
# This script is scheduled to be called by cron every 10 minutes.

/opt/iam_ssh/get_authorized_users.sh | while read user_name; do
  if ! id -u "$user_name" >/dev/null 2>&1; then
    /usr/sbin/adduser "$user_name"
  fi
done