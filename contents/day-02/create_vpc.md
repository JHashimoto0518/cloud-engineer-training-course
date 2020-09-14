# VPCの作成

## ステップ
1. VPCの作成
2. Subnetの作成
3. Internet Gatewayの作成
4. Internet GatewayをVPCにアタッチする
5. Route Tableにルーティングルールを追加
6. Route TableをSubnetに関連付ける

## 前提
環境変数が設定されていること


## VPCの作成

| 属性 | 値 |　
| -------- | -------- | 
| リソース名 | vpc for web |
| CIDR | 192.168.10.0/24 |
|  |  | 


```bash
$ aws ec2 create-vpc --cidr-block 192.168.10.0/24 --tag-specifications ResourceType=vpc,Tags="[{Key=Name,Value=vpc for web}]"
{
    "Vpc": {
        "CidrBlock": "192.168.10.0/24",
        "DhcpOptionsId": "dopt-224b1145",
        "State": "pending",
        "VpcId": "vpc-071e097c0376444bb",
        "OwnerId": "937264738810",
        "InstanceTenancy": "default",
        "Ipv6CidrBlockAssociationSet": [],
        "CidrBlockAssociationSet": [
            {
                "AssociationId": "vpc-cidr-assoc-0d93f3b5da20a8465",
                "CidrBlock": "192.168.10.0/24",
                "CidrBlockState": {
                    "State": "associated"
                }
            }
        ],
        "IsDefault": false,
        "Tags": [
            {
                "Key": "Name",
                "Value": "vpc for web"
            }
        ]
    }
}
```

## VPC IDを環境変数に設定

`.bashrc`に追加する。
```bash
$ echo "export WEB_VPC_ID="`aws ec2 describe-vpcs --filters Name=tag:Name,Values="vpc for web" --query 'Vpcs[].VpcId' --output text` >> ~/.bashrc
```

末尾に追加されたことを確認。
```bash
$ tail -n 3 ~/.bashrc
export S3_BUCKET_NAME=www.$ID.soft-think.com
export S3_ETL_BUCKET_NAME=etl.$ID.soft-think.com
export WEB_VPC_ID=vpc-071e097c0376444bb
```

環境変数を確認。
```bash
$ . ~/.bashrc
$ echo $WEB_VPC_ID 
vpc-071e097c0376444bb
```

以降リソースをつくるときは、この流れは同じ。
1. リソース作成
2. リソースのIDを環境変数に設定

## 東京リージョンのAvailabilityZoneを調べる

```bash
$ aws ec2 describe-availability-zones
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

AZが３つあることがわかる。どのAZを使っても同じだが、今回は`ap-northeast-1a`を使う。

## Subnetの作成

| 属性 | 値 |　
| -------- | -------- |
| リソース名 | vpc-subnet for web |
| CIDR | 192.168.10.0/25 |

```bash
$ aws ec2 create-subnet --vpc-id ${WEB_VPC_ID} --cidr-block 192.168.10.0/25 --availability-zone ap-northeast-1a --tag-specifications ResourceType=subnet,Tags="[{Key=Name,Value=vpc-subnet for
 web}]"
{
    "Subnet": {
        "AvailabilityZone": "ap-northeast-1a",
        "AvailabilityZoneId": "apne1-az4",
        "AvailableIpAddressCount": 123,
        "CidrBlock": "192.168.10.0/25",
        "DefaultForAz": false,
        "MapPublicIpOnLaunch": false,
        "State": "available",
        "SubnetId": "subnet-0afdf5923858ea8f0",
        "VpcId": "vpc-071e097c0376444bb",
        "OwnerId": "937264738810",
        "AssignIpv6AddressOnCreation": false,
        "Ipv6CidrBlockAssociationSet": [],
        "Tags": [
            {
                "Key": "Name",
                "Value": "vpc-subnet for web"
            }
        ],
        "SubnetArn": "arn:aws:ec2:ap-northeast-1:937264738810:subnet/subnet-0afdf5923858ea8f0"
    }
}
```

## Subnet IDを環境変数に設定

`.bashrc`に追加する。
```bash
$ echo "export WEB_VPC_SUBNET_ID="`aws ec2 describe-subnets --filters Name=tag:Name,Values="vpc-subnet for web" --query "Subnets[].SubnetId" --output text` >> ~/.bashrc
```

末尾に追加されたことを確認。
```bash
$ tail -n 3 ~/.bashrc
export S3_ETL_BUCKET_NAME=etl.$ID.soft-think.com
export WEB_VPC_ID=vpc-071e097c0376444bb
export WEB_VPC_SUBNET_ID=subnet-0afdf5923858ea8f0
```

環境変数を確認。
```bash
$ . ~/.bashrc
$ echo $WEB_VPC_SUBNET_ID
subnet-0afdf5923858ea8f0
```

## Internet Gatewayの作成
リソースを作成する。

```bash
$ $ aws ec2 create-internet-gateway --tag-specifications ResourceType=internet-gateway,Tags="[{Key=Name,Value=web vpc gateway}]"
{
    "InternetGateway": {
        "Attachments": [],
        "InternetGatewayId": "igw-06566e29cbf0e6ecc",
        "OwnerId": "937264738810",
        "Tags": [
            {
                "Key": "Name",
                "Value": "web vpc gateway"
            }
        ]
    }
}
```

### Internet Gateway IDを環境変数に設定

`.bashrc`に追加する。
```bash
$ $ echo "export WEB_VPC_GATEWAY_ID="`aws ec2 describe-internet-gateways --filters Name=tag:Name,Values="web vpc gateway" --query "InternetGateways[].InternetGatewayId" --output text` >> ~/.bashrc
```

末尾に追加されたことを確認。
```bash
$ tail -n 3 ~/.bashrc 
export WEB_VPC_ID=vpc-071e097c0376444bb
export WEB_VPC_SUBNET_ID=subnet-0afdf5923858ea8f0
export WEB_VPC_GATEWAY_ID=igw-06566e29cbf0e6ecc
```

環境変数を確認。
```bash
$ . ~/.bashrc 
$ echo $WEB_VPC_GATEWAY_ID
igw-06566e29cbf0e6ecc
```

## Internet GatewayをVPCにアタッチする（関連付ける）

```bash
$ aws ec2 attach-internet-gateway --internet-gateway-id ${WEB_VPC_GATEWAY_ID} --vpc-id ${WEB_VPC_ID}
```

VPCにアタッチされたことを確認する。

```bash
$ aws ec2 describe-internet-gateways --internet-gateway-id ${WEB_VPC_GATEWAY_ID} --query 'InternetGateways[]'
[
    {
        "Attachments": [
            {
                "State": "available",
                "VpcId": "vpc-071e097c0376444bb"
            }
        ],
        "InternetGatewayId": "igw-06566e29cbf0e6ecc",
        "OwnerId": "937264738810",
        "Tags": [
            {
                "Key": "Name",
                "Value": "web vpc gateway"
            }
        ]
    }
]
```

## RouteTableに名前を付ける

## インターネットへのルートを追加

- メインルートテーブル
  - 他のルートテーブルに明示的に関連付けられていないすべてのサブネットのルーティングを制御する
    - VPCを作成するとメインルートテーブルが自動的に割り当てられる。
    - 作成されたルートテーブルには、VPC内のルーティングが既に設定されている。

ここでは、デフォルトルートの宛先をInternet GatewayにしてRoute Tableに追加する。これによりVPC内部宛て以外の通信はすべてインターネットに送られることになる。

TODO:
デフォルトルートとは

**この設定をしないと、クライアントからインターネット越しにVPC内への通信はできない。**

### RouteTableのIDを取得

VPC作成時に自動的にRoute Tableが作成されている。

```bash
$ aws ec2 describe-route-tables --filter "Name=vpc-id,Values=${WEB_VPC_ID}" --query 'RouteTables[]'
[
    {
        "Associations": [
            {
                "Main": true,
                "RouteTableAssociationId": "rtbassoc-05db6162ba04b5fc1",
                "RouteTableId": "rtb-06dadc6127a662bb4",
                "AssociationState": {
                    "State": "associated"
                }
            }
        ],
        "PropagatingVgws": [],
        "RouteTableId": "rtb-06dadc6127a662bb4",
        "Routes": [
            {
                "DestinationCidrBlock": "192.168.10.0/24",
                "GatewayId": "local",
                "Origin": "CreateRouteTable",
                "State": "active"
            }
        ],
        "Tags": [],
        "VpcId": "vpc-071e097c0376444bb",
        "OwnerId": "937264738810"
    }
]
```

### Route TableのIDを環境変数に設定

ルーティングを設定するために、Route TableのIDを取得する。

```bash
$ echo "export WEB_VPC_ROUTE_TABLE_ID="`aws ec2 describe-route-tables --filter "Name=vpc-id,Values=${WEB_VPC_ID}" --query 'RouteTables[].RouteTableId' --output text` >> ~/.bashrc
$ tail -n 3 ~/.bashrc
export WEB_VPC_GATEWAY_ID=igw-06566e29cbf0e6ecc
export WEB_VPC_ROUTE_TABLE_ID=
export WEB_VPC_ROUTE_TABLE_ID=rtb-06dadc6127a662bb4
$ . ~/.bashrc
$ echo $WEB_VPC_ROUTE_TABLE_ID 
rtb-06dadc6127a662bb4
```

### Route Tableにルーティングルールを追加

デフォルトルート`0.0.0.0/0`を追加する。

```bash
$ aws ec2 create-route --route-table-id ${WEB_VPC_ROUTE_TABLE_ID} --destination-cidr-block "0.0.0.0/0" --gateway-id ${WEB_VPC_GATEWAY_ID}
{
    "Return": true
}
```

ルーティングテーブルにデフォルトルートが追加されたことを確認する。

```
$ aws ec2 describe-route-tables --filter "Name=route-table-id,Values=${WEB_VPC_ROUTE_TABLE_ID}" --query "RouteTables[].Routes[]"
[
    {
        "DestinationCidrBlock": "192.168.10.0/24",
        "GatewayId": "local",
        "Origin": "CreateRouteTable",
        "State": "active"
    },
    {
        "DestinationCidrBlock": "0.0.0.0/0",
        "GatewayId": "igw-06566e29cbf0e6ecc",
        "Origin": "CreateRoute",
        "State": "active"
    }
]
```
TODO:
"export REP_ROOT_PATH=`PWD`"

## Route TableをSubnetに関連付ける
```bash
$ aws ec2 associate-route-table --subnet-id ${WEB_VPC_SUBNET_ID} --route-table-id ${WEB_VPC_ROUTE_TABLE_ID}
{
    "AssociationId": "rtbassoc-0b241ce66e1bd61c9",
    "AssociationState": {
        "State": "associated"
    }
}
```

Route TableとSubnetが関連付けられたことを確認する

```bash
$ aws ec2 describe-route-tables --filter "Name=route-table-id,Values=${WEB_VPC_ROUTE_TABLE_ID}" --query 'RouteTables[].Associations'
[
    [
        {
            "Main": true,
            "RouteTableAssociationId": "rtbassoc-05db6162ba04b5fc1",
            "RouteTableId": "rtb-06dadc6127a662bb4",
            "AssociationState": {
                "State": "associated"
            }
        },
        {
            "Main": false,
            "RouteTableAssociationId": "rtbassoc-0b241ce66e1bd61c9",
            "RouteTableId": "rtb-06dadc6127a662bb4",
            "SubnetId": "subnet-0afdf5923858ea8f0",
            "AssociationState": {
                "State": "associated"
            }
        }
    ]
]
```
