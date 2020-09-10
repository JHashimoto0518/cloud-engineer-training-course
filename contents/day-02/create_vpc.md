# VPCの作成

## ステップ
1. VPCの作成
2. Subnetの作成
3. Internet Gatewayの作成
4. Internet GatewayをVPCにアタッチする
5. Route Tableにルーティングルールを追加
6. Route TableをSubnetに関連付ける

## 前提
.bashrcを編集する。

- 以下の環境変数設定は不要（動的な値なので今後.bashrcには定義しない）なので、削除する
    - SV_PUB_IP
    - EC2_PRI_IP
    - EC2_INS_ID
    - EC2_SG_GID
- この手順では、以下の環境変数を使用するので、設定しておくこと
    - USER_ID

```bash=
[root@server ~]# source .bashrc
```

## VPCの作成
```bash=
[root@server ~]# export CIDR_BLOCK="192.168.10.0/24"
[root@server ~]# aws ec2 create-vpc --cidr-block ${CIDR_BLOCK}
{
    "Vpc": {
        "CidrBlock": "192.168.10.0/24",
        "DhcpOptionsId": "dopt-3a97a55d",
        "State": "pending",
        "VpcId": "vpc-???",
        "OwnerId": "773217231744",
        "InstanceTenancy": "default",
        "Ipv6CidrBlockAssociationSet": [],
        "CidrBlockAssociationSet": [
            {
                "AssociationId": "vpc-cidr-assoc-0e8b27a388ce7496f",
                "CidrBlock": "192.168.10.0/24",
                "CidrBlockState": {
                    "State": "associated"
                }
            }
        ],
        "IsDefault": false
    }
}
```

作成されたリソースの情報が出力される。Idを手動でコピーして環境変数に設定する。以下この流れは同じ。

```bash=
[root@server ~]# export VPC_ID="vpc-???"
[root@server ~]# echo ${VPC_ID}
vpc-???
```

## VPCに名前を付ける
```bash=
[root@server ~]# export VPC_TAG="${USER_ID} vpc for http ec2"
[root@server ~]# echo $VPC_TAG
hashimoto-j vpc for http ec2
[root@server ~]# aws ec2 create-tags --resources ${VPC_ID} --tags "Key=Name,Value=${VPC_TAG}"
[root@server ~]# aws ec2 describe-vpcs --vpc-ids "${VPC_ID}" --query 'Vpcs[].Tags[]'
[
    {
        "Key": "Name",
        "Value": "hashimoto-j vpc for http ec2"
    }
]
```

マネジメントコンソールで名前が付いていることを確認する

## AvailabilityZoneを調べる

```bash=
[root@server ~]# aws ec2 describe-availability-zones
{
    "AvailabilityZones": [
        {
            "State": "available",
            "OptInStatus": "opt-in-not-required",
            "Messages": [],
            "RegionName": "ap-northeast-1",
            "ZoneName": "ap-northeast-1a",
            "ZoneId": "apne1-az4",
            "GroupName": "ap-northeast-1",
            "NetworkBorderGroup": "ap-northeast-1"
        },
        {
            "State": "available",
            "OptInStatus": "opt-in-not-required",
            "Messages": [],
            "RegionName": "ap-northeast-1",
            "ZoneName": "ap-northeast-1c",
            "ZoneId": "apne1-az1",
            "GroupName": "ap-northeast-1",
            "NetworkBorderGroup": "ap-northeast-1"
        },
        {
            "State": "available",
            "OptInStatus": "opt-in-not-required",
            "Messages": [],
            "RegionName": "ap-northeast-1",
            "ZoneName": "ap-northeast-1d",
            "ZoneId": "apne1-az2",
            "GroupName": "ap-northeast-1",
            "NetworkBorderGroup": "ap-northeast-1"
        }
    ]
}
```

東京RegionにAZが３つあるのがわかる。どのAZを使っても同じだが、今回はap-northeast-1aを使う。

```bash=+
[root@server ~]# export AVAILABILITY_ZONE="ap-northeast-1a"
[root@server ~]# echo $AVAILABILITY_ZONE 
ap-northeast-1a
```

## Subnetの作成
```bash=
[root@server ~]# export SUBNET_CIDR_BLOCK="192.168.10.0/25"
[root@server ~]# aws ec2 create-subnet --vpc-id ${VPC_ID} --cidr-block ${SUBNET_CIDR_BLOCK} --availability-zone ${AVAILABILITY_ZONE}
{
    "Subnet": {
        "AvailabilityZone": "ap-northeast-1a",
        "AvailabilityZoneId": "apne1-az4",
        "AvailableIpAddressCount": 123,
        "CidrBlock": "192.168.10.0/25",
        "DefaultForAz": false,
        "MapPublicIpOnLaunch": false,
        "State": "pending",
        "SubnetId": "subnet-???",
        "VpcId": "vpc-???",
        "OwnerId": "773217231744",
        "AssignIpv6AddressOnCreation": false,
        "Ipv6CidrBlockAssociationSet": [],
        "SubnetArn": "arn:aws:ec2:ap-northeast-1:773217231744:subnet/subnet-???"
    }
}
[root@server ~]# export SUBNET_ID="subnet-???"
[root@server ~]# echo ${SUBNET_ID}
subnet-???
```

## Subnetに名前を付ける
```bash=
[root@server ~]# export SUBNET_TAG="${USER_ID} public subnet for http ec2"
[root@server ~]# aws ec2 create-tags --resources ${SUBNET_ID} --tags "Key=Name,Value=${SUBNET_TAG}"
[root@server ~]# aws ec2 describe-subnets --subnet-id=${SUBNET_ID} --query 'Subnets[].Tags[]'
[
    {
        "Key": "Name",
        "Value": "hashimoto-j public subnet for http ec2"
    }
]
```

マネジメントコンソールで名前が付いていることを確認する

## Internet Gatewayの作成
```bash=
[root@server ~]# aws ec2 create-internet-gateway
{
    "InternetGateway": {
        "Attachments": [],
        "InternetGatewayId": "igw-???",
        "Tags": []
    }
}
[root@server ~]# export GATEWAY_ID="igw-???"
[root@server ~]# echo ${GATEWAY_ID}
igw-???
```

## Internet Gatewayへ名前を追加する
```bash=
[root@server ~]# export GATEWAY_TAG="${USER_ID} gateway for http ec2"
[root@server ~]# aws ec2 create-tags --resources ${GATEWAY_ID} --tags "Key=Name,Value=${GATEWAY_TAG}"
[root@server ~]# aws ec2 describe-internet-gateways --internet-gateway-ids ${GATEWAY_ID}
{
    "InternetGateways": [
        {
            "Attachments": [],
            "InternetGatewayId": "igw-???",
            "OwnerId": "773217231744",
            "Tags": [
                {
                    "Key": "Name",
                    "Value": "hashimoto-j gateway for http ec2"
                }
            ]
        }
    ]
}
```

マネジメントコンソールで名前が付いていることを確認する

## Internet GatewayをVPCにアタッチする（関連付ける）

```bash=
[root@server ~]# aws ec2 attach-internet-gateway --internet-gateway-id ${GATEWAY_ID} --vpc-id ${VPC_ID}
[root@server ~]# aws ec2 describe-internet-gateways --internet-gateway-id ${GATEWAY_ID} --query 'InternetGateways[]'
[
    {
        "Attachments": [
            {
                "State": "available",
                "VpcId": "vpc-???"
            }
        ],
        "InternetGatewayId": "igw-???",
        "OwnerId": "773217231744",
        "Tags": [
            {
                "Key": "Name",
                "Value": "hashimoto-j gateway for http ec2"
            }
        ]
    }
]
```

アタッチされたVPCのIDが確認できる。

## RouteTableのIDを取得

VPC作成時に自動的にRoute Tableが作成されている。ルーティングを設定するために、Route TableのIDを取得する。

```bash=
[root@server ~]# aws ec2 describe-route-tables --filter "Name=vpc-id,Values=${VPC_ID}" --query 'RouteTables[]'
[
    {
        "Associations": [
            {
                "Main": true,
                "RouteTableAssociationId": "rtbassoc-00382ad004d79439f",
                "RouteTableId": "rtb-???",
                "AssociationState": {
                    "State": "associated"
                }
            }
        ],
        "PropagatingVgws": [],
        "RouteTableId": "rtb-???",
        "Routes": [
            {
                "DestinationCidrBlock": "192.168.10.0/24",
                "GatewayId": "local",
                "Origin": "CreateRouteTable",
                "State": "active"
            }
        ],
        "Tags": [],
        "VpcId": "vpc-???",
        "OwnerId": "773217231744"
    }
]
[root@server ~]# export ROUTE_TABLE_ID="rtb-???"
[root@server ~]# echo $ROUTE_TABLE_ID 
rtb-???
```

## Route Tableに名前をつける
```bash=
[root@server ~]# export ROUTE_TABLE_TAG="${USER_ID} route table for http ec2"
[root@server ~]# echo $ROUTE_TABLE_TAG
hashimoto-j route table for http ec2
[root@server ~]# aws ec2 create-tags --resources ${ROUTE_TABLE_ID} --tags "Key=Name,Value=${ROUTE_TABLE_TAG}"
[root@server ~]# aws ec2 describe-route-tables --filter "Name=route-table-id,Values=${ROUTE_TABLE_ID}" --query 'RouteTables[].Tags[]'
[
    {
        "Key": "Name",
        "Value": "hashimoto-j route table for http ec2"
    }
]
```

マネジメントコンソールで名前が付いていることを確認する

## Route Tableにルーティングルールを追加

VPC作成時に自動的に作成されたRoute Tableには、VPC内のルーティングが既に設定されている。

ここでは、デフォルトルートの宛先をInternet GatewayにしてRoute Tableに追加する。これによりVPC内部宛て以外の通信はすべてインターネットに送られることになる。

この設定をしないと、クライアントからインターネット越しにVPC内への通信はできない。

```bash=
[root@server ~]# export DESTINATION_CIDR_BLOCK="0.0.0.0/0"
[root@server ~]# aws ec2 create-route --route-table-id ${ROUTE_TABLE_ID} --destination-cidr-block ${DESTINATION_CIDR_BLOCK} --gateway-id ${GATEWAY_ID}
{
    "Return": true
}
[root@server ~]# aws ec2 describe-route-tables --filter "Name=route-table-id,Values=${ROUTE_TABLE_ID}"
{
    "RouteTables": [
        {
            "Associations": [
                {
                    "Main": true,
                    "RouteTableAssociationId": "rtbassoc-00382ad004d79439f",
                    "RouteTableId": "rtb-???",
                    "AssociationState": {
                        "State": "associated"
                    }
                }
            ],
            "PropagatingVgws": [],
            "RouteTableId": "rtb-???",
            "Routes": [
                {
                    "DestinationCidrBlock": "192.168.10.0/24",
                    "GatewayId": "local",
                    "Origin": "CreateRouteTable",
                    "State": "active"
                },
                {
                    "DestinationCidrBlock": "0.0.0.0/0",
                    "GatewayId": "igw-???",
                    "Origin": "CreateRoute",
                    "State": "active"
                }
            ],
            "Tags": [
                {
                    "Key": "Name",
                    "Value": "hashimoto-j route table for http ec2"
                }
            ],
            "VpcId": "vpc-???",
            "OwnerId": "773217231744"
        }
    ]
}
```
`Routes`にデフォルトルートが追加されたことが確認できる。

```json=
{
    "DestinationCidrBlock": "0.0.0.0/0",
    "GatewayId": "igw-???",
    "Origin": "CreateRoute",
    "State": "active"
}
```

## Route TableをSubnetに関連付ける
```bash=
[root@server ~]# aws ec2 associate-route-table --subnet-id ${SUBNET_ID} --route-table-id ${ROUTE_TABLE_ID}
{
    "AssociationId": "rtbassoc-???",
    "AssociationState": {
        "State": "associated"
    }
}
[root@server ~]# aws ec2 describe-route-tables --filter "Name=route-table-id,Values=${ROUTE_TABLE_ID}" --query 'RouteTables[].Associations'
[
    [
        {
            "Main": true,
            "RouteTableAssociationId": "rtbassoc-00382ad004d79439f",
            "RouteTableId": "rtb-???",
            "AssociationState": {
                "State": "associated"
            }
        },
        {
            "Main": false,
            "RouteTableAssociationId": "rtbassoc-???",
            "RouteTableId": "rtb-???",
            "SubnetId": "subnet-???",
            "AssociationState": {
                "State": "associated"
            }
        }
    ]
]
```

Route TableとSubnetが関連付けられたことが確認できる。
