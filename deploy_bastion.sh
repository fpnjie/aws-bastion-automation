#!/bin/bash

# Set AWS Region
AWS_REGION="us-east-1"
INSTANCE_TYPE="t3.micro"
AMI_ID="ami-0c55b159cbfafe1f0"  # Change based on your region
KEY_NAME="your-key-pair"  # Replace with your actual key pair
SECURITY_GROUP_NAME="bastion-sg"
ALLOWED_IP="YOUR_IP/32"  # Replace with your IP address

# Create a Security Group
SECURITY_GROUP_ID=$(aws ec2 create-security-group \
  --group-name $SECURITY_GROUP_NAME \
  --description "Allow SSH from trusted IPs" \
  --region $AWS_REGION \
  --query 'GroupId' --output text)

# Allow SSH Access from a Trusted IP
aws ec2 authorize-security-group-ingress \
  --group-id $SECURITY_GROUP_ID \
  --protocol tcp --port 22 --cidr $ALLOWED_IP \
  --region $AWS_REGION

# Launch EC2 Instance
INSTANCE_ID=$(aws ec2 run-instances \
  --image-id $AMI_ID \
  --instance-type $INSTANCE_TYPE \
  --key-name $KEY_NAME \
  --security-group-ids $SECURITY_GROUP_ID \
  --region $AWS_REGION \
  --query 'Instances[0].InstanceId' --output text)

# Wait for the instance to start
aws ec2 wait instance-running --instance-ids $INSTANCE_ID --region $AWS_REGION

# Get Public IP of the instance
INSTANCE_IP=$(aws ec2 describe-instances \
  --instance-ids $INSTANCE_ID \
  --query 'Reservations[0].Instances[0].PublicIpAddress' --output text --region $AWS_REGION)

echo "Bastion Host is running at: $INSTANCE_IP"

