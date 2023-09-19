#!/bin/bash
InstanceId="i-0dc7ffe31c002cfa7"
OldPublicIpAddress=$(aws ec2 describe-instances --filters "Name=instance-id,Values=$InstanceId" --query  "Reservations[*].Instances[*].NetworkInterfaces[0].Association.PublicIp" --output text)
NetworkInterfaceId=$(aws ec2 describe-instances --filters "Name=instance-id,Values=$InstanceId" --query  "Reservations[*].Instances[*].NetworkInterfaces[0].NetworkInterfaceId" --output text)
PrivateIpAddress=$(aws ec2 describe-instances --filters "Name=instance-id,Values=$InstanceId" --query  "Reservations[*].Instances[*].NetworkInterfaces[0].PrivateIpAddress" --output text)
NewAllocationId=$(aws ec2 allocate-address --domain vpc --query "AllocationId" --output text)
aws ec2 associate-address --allocation-id $NewAllocationId --network-interface-id $NetworkInterfaceId --private-ip-address $PrivateIpAddress
aws ec2 release-address --allocation-id $(aws ec2 describe-addresses --filters "Name=public-ip,Values=$OldPublicIpAddress" --query "Addresses[*].[AllocationId]" --output text)
NewPublicIp=$(aws ec2 describe-addresses --filters "Name=network-interface-id,Values=$NetworkInterfaceId" --filters "Name=private-ip-address,Values=$PrivateIpAddress" --query 'Addresses[*].PublicIp' --output text)
echo "New Elastic IP: "$NewPublicIp