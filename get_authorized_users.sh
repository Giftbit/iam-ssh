#!/bin/bash
/opt/iam_ssh/authorized_groups.sh | xargs -L 1 -I '{}' aws iam get-group --group-name '{}' --query "Users[].[UserName]" --output text | sort | uniq