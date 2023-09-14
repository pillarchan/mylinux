#!/bin/bash
INSTANCE_ID=$(aliyun ecs DescribeInstances --InstanceName sz_gather --output cols="InstanceId" rows="Instances.Instance[]" | sed -n "3 p")
OLDIP=$(aliyun ecs DescribeInstances --InstanceName sz_gather --output cols="IpAddress" rows="Instances.Instance[].EipAddress" | sed -n "3 p")
OLDIPID=$(aliyun vpc DescribeEipAddresses --region cn-shenzhen --RegionId 'cn-shenzhen' --EipAddress $OLDIP --output cols=AllocationId rows=EipAddresses.EipAddress[] | sed -n "3 p")

aliyun vpc AllocateEipAddress --region cn-shenzhen --RegionId 'cn-shenzhen' --Bandwidth 100 --InstanceChargeType PostPaid --InternetChargeType PayByTraffic

NEWIP=$(aliyun vpc DescribeEipAddresses --region cn-shenzhen --RegionId 'cn-shenzhen' --Status Available --output cols=IpAddress rows=EipAddresses.EipAddress[] | sed -n "3 p")
NEWIPID=$(aliyun vpc DescribeEipAddresses --region cn-shenzhen --RegionId 'cn-shenzhen' --Status Available --output cols=AllocationId rows=EipAddresses.EipAddress[] | sed -n "3 p")

aliyun vpc UnassociateEipAddress --region cn-shenzhen --RegionId 'cn-shenzhen' --AllocationId $OLDIPID --InstanceId $INSTANCE_ID
sleep 10
aliyun vpc AssociateEipAddress --region cn-shenzhen --RegionId 'cn-shenzhen' --AllocationId $NEWIPID --InstanceId $INSTANCE_ID --endpoint vpc-vpc.cn-shenzhen.aliyuncs.com

aliyun vpc ReleaseEipAddress --region cn-shenzhen --RegionId 'cn-shenzhen' --AllocationId $OLDIPID
echo $NEWIP