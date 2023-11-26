#!/bin/bash

cd terraform
terraform destroy -var="users=[$(cat ../users.txt | cut -d@ -f1 | tr . - | sed 's/.*/"&"/' | paste -sd,)]"