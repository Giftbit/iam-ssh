#!/bin/bash
/opt/iam_ssh/get_authorized_users.sh | while read user_name; do
  if ! id -u "$user_name" >/dev/null 2>&1; then
    /usr/sbin/adduser "$user_name"
  fi
done