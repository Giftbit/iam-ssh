#!/bin/bash

# This script gets the authorized groups for this instance, and for each one, retrieves
# the list of users associated with the named groups. Finally, they are sorted and 
# duplicates are removed

/opt/iam_ssh/authorized_groups.sh | xargs -L 1 -I '{}' aws iam get-group --group-name '{}' --query "Users[].[UserName]" --output text | sort | uniq