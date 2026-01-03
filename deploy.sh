#!/bin/bash
set -e

ENV=$1

echo "Deploying environment: $ENV"

cd terraform

terraform init -input=false

terraform apply -auto-approve \
  -var="environment=$ENV" \
  -var="instance_count=2"

cd ..

ansible-playbook \
  -i ansible/inventory.aws_ec2.yml \
  ansible/playbook.yml \
  --limit $ENV

