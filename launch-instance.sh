#!/bin/bash
set -e

# Define variables
AMI_ID="ami-0090481fc3887c878"
REGION="us-west-2"
INSTANCE_TYPE="m5.xlarge"
KEY_NAME="zk-us-west-2-new"  # Replace with your key pair name
SECURITY_GROUP="bastion-sg"       # Replace with your security group if needed

# Launch EC2 instance
echo "Launching EC2 instance..."
INSTANCE_ID=$(aws ec2 run-instances \
  --image-id $AMI_ID \
  --instance-type $INSTANCE_TYPE \
  --key-name $KEY_NAME \
  --security-groups $SECURITY_GROUP \
  --region $REGION \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=ARM-Builder}]' \
  --query 'Instances[0].InstanceId' \
  --output text)

echo "Waiting for instance $INSTANCE_ID to be running..."
aws ec2 wait instance-running --instance-ids $INSTANCE_ID --region $REGION

# Get public IP address
PUBLIC_IP=$(aws ec2 describe-instances \
  --instance-ids $INSTANCE_ID \
  --region $REGION \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text)

echo "Instance $INSTANCE_ID is running!"
echo "Public IP: $PUBLIC_IP"
echo ""
echo "Connect to the instance with:"
echo "ssh -i ~/.ssh/$KEY_NAME.pem ec2-user@$PUBLIC_IP"
echo ""
echo "After connecting, run the following commands:"
echo "git clone https://github.com/yourusername/arm-build-on-aws-linux-2-x86-test.git"
echo "cd arm-build-on-aws-linux-2-x86-test"
echo "chmod +x setup.sh build.sh"
echo "./setup.sh"
echo "# Log out and log back in"
echo "./build.sh"
