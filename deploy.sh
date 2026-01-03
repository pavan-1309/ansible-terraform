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

echo "Fixing SSH key permissions..."
chmod 600 ~/.ssh/my-keypair.pem

echo "Waiting for instances to be ready..."
sleep 60

echo "Installing AWS collection..."
ansible-galaxy collection install amazon.aws --force

echo "Testing dynamic inventory..."
ansible-inventory --list

echo "Running playbook with dynamic inventory..."
ansible-playbook \
  -i ansible/inventory.aws_ec2.yml \
  ansible/playbook.yml \
  --limit "$ENV"

