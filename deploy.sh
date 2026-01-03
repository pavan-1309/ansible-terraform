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

cd ansible

echo "Fixing SSH key permissions..."
chmod 600 ~/.ssh/my-keypair.pem

echo "Waiting for instances to be ready..."
sleep 60

echo "Installing AWS collection..."
ansible-galaxy collection install amazon.aws --force

echo "Testing AWS credentials..."
aws ec2 describe-instances --region ap-south-1 --query 'Reservations[*].Instances[*].[InstanceId,State.Name,Tags[?Key==`Environment`].Value|[0]]' --output table

echo "Testing dynamic inventory..."
ANSIBLE_CONFIG=./ansible.cfg ansible-inventory --list -vvv

echo "Running playbook with dynamic inventory..."
ANSIBLE_CONFIG=./ansible.cfg ansible-playbook \
  -i inventory.aws_ec2.yml \
  playbook.yml \
  --limit "$ENV"

