#!/bin/bash
aws --region=us-west-2 ec2 describe-tags --filters "Name=resource-id,Values=$(curl http://169.254.169.254/latest/meta-data/instance-id)" "Name=key,Values=AuthorizedUsersGroup" --query "Tags[].Value" --output text | tr "," "\n"
