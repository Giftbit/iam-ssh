#!/bin/bash -e
username=$1

if /usr/local/bin/get_authorized_users.sh | grep "^$username$"; then
  aws iam list-ssh-public-keys --user-name $username --query "SSHPublicKeys[?Status == 'Active'].[SSHPublicKeyId]" --output text | while read ssh_key_id; do
  	aws iam get-ssh-public-key --user-name $username --ssh-public-key-id $ssh_key_id --query "SSHPublicKey.SSHPublicKeyBody" --encoding ssh --output txt
  done
fi