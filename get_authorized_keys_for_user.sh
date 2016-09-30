#!/bin/bash -e
username=$1

if /opt/iam_ssh/get_authorized_users.sh | grep "^$username$" >/dev/null 2>&1; then
  aws iam list-ssh-public-keys --user-name $username --query "SSHPublicKeys[?Status == 'Active'].[SSHPublicKeyId]" --output text | while read ssh_key_id; do
    aws iam get-ssh-public-key --user-name $username --ssh-public-key-id $ssh_key_id --encoding SSH --query "SSHPublicKey.SSHPublicKeyBody" --output text
  done
fi