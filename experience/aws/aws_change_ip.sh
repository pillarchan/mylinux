#/bin/bash
InstanceId="i-095ca854ac7743cea"
OldPublicIpAddress=$(aws ec2 describe-instances --filters "Name=instance-id,Values=$InstanceId" --query "Reservations[*].Instances[*].[PublicIpAddress]" --output text)
NewPublicIpAddress=$(aws ec2 allocate-address --domain vpc --query "PublicIp" --output text)
result=$(aws ec2 associate-address --instance-id $InstanceId --public-ip $NewPublicIpAddress)
aws ec2 release-address --allocation-id $(aws ec2 describe-addresses --filters "Name=public-ip,Values=$OldPublicIpAddress" --query "Addresses[*].[AllocationId]" --output text)
echo "New Elastic IP: "$NewPublicIpAddress