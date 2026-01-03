#!/bin/bash
set -e

ENV=$1

if [ -z "$ENV" ]; then
  echo "Usage: $0 <environment>"
  echo "Example: $0 test"
  exit 1
fi

echo "Deploying environment: $ENV"

cd terraform

terraform init -input=false

terraform apply -auto-approve \
  -var="environment=$ENV" \
  -var="instance_count=2"

cd ..

echo "Waiting for instances to be ready..."
sleep 60

ansible-playbook \
  -i ansible/inventory.aws_ec2.yml \
  ansible/playbook.yml \
  --limit "$ENV"

