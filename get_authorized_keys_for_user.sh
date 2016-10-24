#!/bin/bash -e

# This script verifies that the requested user is in the list of authorized users, 
# and if they are, retrieves the list of public keys associated with them.
#
# If the user is not authorized or has no public keys, this script will return no
# public keys and thus SSH will have no public keys to match, rejecting the request
# to connect.

username=$1

# Verify that the user attempting to connect is in the authorized groups
if /opt/iam_ssh/get_authorized_users.sh | grep "^$username$" >/dev/null 2>&1; then
  
  # Get the list of Public Keys for the authorized user, if any
  aws iam list-ssh-public-keys --user-name $username --query "SSHPublicKeys[?Status == 'Active'].[SSHPublicKeyId]" --output text | while read ssh_key_id; do
    aws iam get-ssh-public-key --user-name $username --ssh-public-key-id $ssh_key_id --encoding SSH --query "SSHPublicKey.SSHPublicKeyBody" --output text
  done
fi