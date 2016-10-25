# iam-ssh

This library provides a flexible a method for authorizing and
authenticating user logins via SSH. It does this by using EC2 tags
to specify the names of authorized IAM groups that should have
access to this instance, and SSH Public keys on IAM users to
centrally store and manage the list of authorized keys for each
user.

## IAM SSH Access Policy

For this system to work correctly, you need to provide access to
the relevant IAM data. An example of this is provided in the
[policy.json][1] file. Below we will cover the major permissions
needed, and what they are used for.

### ec2:DescribeTags

This permission is used to get the `AuthorizedUsersGroup` tag
from the instance. This tells us the group or groups that contain
users who should be authorized to access this instance.

If you know the list of instance ARNs that would be using this
script, the policy could be changed such that the `Resource`
list contains ARNs for those instance only.

### iam:GetGroup

When we've determined which group is authorized to access the
instance, we need to retrieve the group to determine the 
authorized users. This is used for both creating users on the
instance, and checking at connection time if a user is (still)
authorized. 

If you know the specific groups that are allowed for an instance
or set of instances, the policy could be changed such that
the `Resource` list contains ARNs for those groups only.

### iam:ListSSHPublicKeys & iam:GetSSHPublicKey

Once we've determined that a user is authorized, we need to 
get their SSH Keys, to provide them to the SSH Server for 
authentication.

## IAM Resources

To authorize a set of users to log into a machine, you first need
to [create an IAM Group][2]. To this group you will add any users
you want to be able to login. Next, tag the instances that you want
to authorize logins by this group using the tag `AuthorizedUsersGroup`
where the value is the name of the group (case sensitive). Finally,
ensure that any authorized users have their
[SSH Public key added to their IAM user][3].

Note, users added to this group will be added on installation, and
an update is scheduled every 10 minutes. Verifying that a user
is in the authorized group, and retrieving their SSH keys happens
on each connection. Thus, if you want to remove a users ability
to SSH into one of the configured machines, remove that user
from the relevant group, or remove their SSH Public key from
their profile.

## Installation

To install IAM SSH on one of your servers, you can add it using
the user data you pass to the instance. A sample value for the
user data is as follows:

```bash
#!/bin/bash
SHASUM="d4fb1c6da99c0b42d3b41329ebc630e19dc75ffbb223b6d7afd1e45a1ec01c28"
curl https://raw.githubusercontent.com/Giftbit/iam-ssh/3d665e59fc90ccd5a4e5eba46748ad2a85a135af/install.sh -o install.sh
if echo "$SHASUM *install.sh" | shasum -a 256 -c -; then
  chmod 755 install.sh
  ./install.sh
fi
```

This script downloads the latest release version of the scripts,
adds the list of authorized users from the IAM group referenced in 
this instances `AuthorizedUsersGroup` tag, sets this import to check
for any missing users once every 10 minutes, and associates the
`get_authorized_keys_for_user.sh` script with the
`AuthorizedKeysCommand` in the SSH Server configuration.

-----

Copyright 2016 Giftbit Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

[1]: /policy.json
[2]: http://docs.aws.amazon.com/IAM/latest/UserGuide/id_groups_create.html
[3]: http://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_CreateAccessKey
