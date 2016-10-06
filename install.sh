#!/bin/bash
VERSION="0.1.0"
SHA256="3c0a998dfa7b5c4fe9a90f01671801c666d103df4e7ef9e111ff422d8c106828"

# Install the list of functions that we use
curl https://codeload.github.com/Giftbit/iam-ssh/tar.gz/$VERSION -o iam-ssh.tar.gz

# Verify that the SHA meets what we expect
if ! echo "$SHA256 *iam-ssh.tar.gz" | shasum -a 256 -c -; then
  echo "The SHA value did not match the expected"
  exit 1
fi

# If the SHA matched, then continue with installation
mkdir /opt/iam_ssh
tar --strip-components 1 -xzf iam-ssh.tar.gz -C /opt/iam_ssh
rm iam-ssh.tar.gz
chmod 755 /opt/iam_ssh/*.sh

# Set up regularly scheduled importing of users from our authorized groups
echo "*/10 * * * * root /opt/iam_ssh/import_users.sh" > /etc/cron.d/import_users
chmod 644 /etc/cron.d/import_users

# Bootstrap the authorized users
/opt/iam_ssh/import_users.sh

if ! cat /etc/ssh/sshd_config | grep "AuthorizedKeysCommand /opt/iam_ssh/get_authorized_keys_for_user.sh"; then
  # Add the Authorized keys command to pull the keys for the user from IAM 
  echo "" >> /etc/ssh/sshd_config
  echo "AuthorizedKeysCommand /opt/iam_ssh/get_authorized_keys_for_user.sh" >> /etc/ssh/sshd_config
  echo "AuthorizedKeysCommandUser nobody" >> /etc/ssh/sshd_config
fi

# Restart sshd so that it has the updated configuration
service sshd restart
