#!/bin/bash
# This script installs the Amazon Cloud Agent on an Ubuntu EC2 instance.
# PREREQUISITE: An IAM role with the policy CloudWatchAgentServerPolicy must be attached to the EC2 instance.
# Enhancement: Convert this to ansible playbook to automate the SSH step and attaching of IAM role to EC2.
cd /home/ubuntu
echo "Creating a folder for installation files..."
mkdir monitoring
cd monitoring
echo "Downloading packages from AWS..."
sudo wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
sudo wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb.sig
echo "Installing AWS CloudWatch Agent..."
sudo dpkg -i -E ./amazon-cloudwatch-agent.deb
echo "Creating config file for the agent... This config file will send disk, CPU, and memory usage metrics to CloudWatch."
sudo echo -e "\n{\n\t\""metrics"\": {\n\t\t\""metrics_collected"\": {\n\t\t\t\""disk"\": {\n\t\t\t\t\""measurement"\": [\n\t\t\t\t\t\""disk_used_percent"\"\n\t\t\t\t]\n\t\t\t},\n\t\t\t\""mem"\": {\n\t\t\t\t\""measurement"\": [\n\t\t\t\t\t\""mem_used_percent"\"\n\t\t\t\t]\n\t\t\t},\n\t\t\t\""swap"\": {\n\t\t\t\t\""measurement"\": [\n\t\t\t\t\t\""swap_used_percent"\"\n\t\t\t\t]\n\t\t\t}\n\t\t},\n\t\t\""append_dimensions"\": {\n\t\t\t\""ImageId"\": \""\${aws:ImageId}"\",\n\t\t\t\""InstanceId"\": \""\${aws:InstanceId}"\",\n\t\t\t\""InstanceType"\": \""\${aws:InstanceType}"\",\n\t\t\t\""AutoScalingGroupName"\": \""\${aws:AutoScalingGroupName}"\"\n\t\t}\n\t}\n}" >> /home/ubuntu/monitoring/config.json
echo "Starting the agent..."
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/home/ubuntu/monitoring/config.json -s
echo "Checking if the agent is running..."
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -m ec2 -a status
echo "Displaying logs after starting the service..."
cat /opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log
rm -rf /tmp/install.sh
