
# VPCの構築

## ステップ
1. VPCの作成
2. サブネットの作成
3. インターネットゲートウェイの作成
4. インターネットゲートウェイをVPCにアタッチする
5. カスタムルートテーブルを作成
6. カスタムルートテーブルにルーティングルールを追加
7. カスタムルートテーブルをサブネットに関連付ける

## VPCの作成

| 属性 | 値 | 意味 |
| --------| -------- | --------|
| リソース名 | web-vpc |  |
| CIDR | 192.168.10.0/24 | このVPCに割り当てるネットワーク |
| DNS解決 | 有効 | DNS解決がサポートされているか |
| DNSホスト名 | 有効 | このVPCにあるEC2インスタンスがパブリックDNSホスト名を取得するか |


```bash
$ aws ec2 create-vpc \
--cidr-block 192.168.10.0/24 \
--tag-specifications ResourceType=vpc,Tags="[{Key=Name,Value=web-vpc}]"
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
                "Value": "web-vpc"
            }
        ]
    }
}
```

### VPCのIDを環境変数に設定

環境変数を`~/set_variables_day_02.sh`に追加する。
```bash
$ echo "export WEB_VPC_ID="`aws ec2 describe-vpcs \
--filters Name=tag:Name,Values="web-vpc" \
--query 'Vpcs[].VpcId' \
--output text` >> ~/set_variables_day_02.sh
```

末尾に追加されたことを確認。
```bash
$ tail -n 1 ~/set_variables_day_02.sh
export WEB_VPC_ID=vpc-071e097c0376444bb
```

環境変数を確認。
```bash
$ . ~/set_variables_day_02.sh
$ echo $WEB_VPC_ID 
vpc-071e097c0376444bb
```

以降リソースをつくるときは、この流れは同じ。
1. リソース作成
2. リソースのIDを環境変数に設定

## DNS解決

設定値を確認する。

```bash
$ aws ec2 describe-vpc-attribute \
--vpc-id ${WEB_VPC_ID} \
--attribute enableDnsSupport
{
    "VpcId": "vpc-06b8bc583831e40c6",
    "EnableDnsSupport": {
        "Value": true
    }
}
```

有効になっているので、設定不要。

## DNSホスト名

設定値を確認する。

```bash
$ aws ec2 describe-vpc-attribute \
--vpc-id ${WEB_VPC_ID} \
--attribute enableDnsHostnames
{
    "VpcId": "vpc-06b8bc583831e40c6",
    "EnableDnsHostnames": {
        "Value": false
    }
}
```

無効になっているので、有効にする。

```bash
$ aws ec2 modify-vpc-attribute \
--vpc-id ${WEB_VPC_ID} \
--enable-dns-hostnames
$ aws ec2 describe-vpc-attribute \
--vpc-id ${WEB_VPC_ID} \
--attribute enableDnsHostnames
{
    "VpcId": "vpc-06b8bc583831e40c6",
    "EnableDnsHostnames": {
        "Value": true
    }
}
```

## サブネットの作成

### 東京リージョンのAvailabilityZoneを調べる

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

### サブネットの作成

| 属性 | 値 |
| --------| -------- |
| リソース名 | web-vpc-subnet |
| CIDR | 192.168.10.0/25 |
| AZ | ap-northeast-1a |

```bash
$ aws ec2 create-subnet \
--vpc-id ${WEB_VPC_ID} \
--cidr-block 192.168.10.0/25 \
--availability-zone ap-northeast-1a \
--tag-specifications ResourceType=subnet,Tags="[{Key=Name,Value=web-vpc-subnet}]"
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
                "Value": "web-vpc-subnet"
            }
        ],
        "SubnetArn": "arn:aws:ec2:ap-northeast-1:937264738810:subnet/subnet-0afdf5923858ea8f0"
    }
}
```

### サブネットIDを環境変数に設定

`~/set_variables_day_02.sh`に追加する。
```bash
$ echo "export WEB_VPC_SUBNET_ID="`aws ec2 describe-subnets \
--filters Name=tag:Name,Values="web-vpc-subnet" \
--query "Subnets[].SubnetId" \
--output text` >> ~/set_variables_day_02.sh
$ . ~/set_variables_day_02.sh
$ echo $WEB_VPC_SUBNET_ID
subnet-0afdf5923858ea8f0
```

## インターネットゲートウェイの作成

```bash
$ aws ec2 create-internet-gateway \
--tag-specifications ResourceType=internet-gateway,Tags="[{Key=Name,Value=web-vpc-gateway}]"
{
    "InternetGateway": {
        "Attachments": [],
        "InternetGatewayId": "igw-06566e29cbf0e6ecc",
        "OwnerId": "937264738810",
        "Tags": [
            {
                "Key": "Name",
                "Value": "web-vpc-gateway"
            }
        ]
    }
}
```

### インターネットゲートウェイのIDを環境変数に設定

`~/set_variables_day_02.sh`に追加する。
```bash
$ echo "export WEB_VPC_GATEWAY_ID="`aws ec2 describe-internet-gateways \
--filters Name=tag:Name,Values="web-vpc-gateway" \
--query "InternetGateways[].InternetGatewayId" \
--output text` >> ~/set_variables_day_02.sh
$ . ~/set_variables_day_02.sh
$ echo $WEB_VPC_GATEWAY_ID
igw-06566e29cbf0e6ecc
```

## インターネットゲートウェイをVPCにアタッチする
作成したインターネットゲートウェイをVPCに関連付ける。

```bash
$ aws ec2 attach-internet-gateway \
--internet-gateway-id ${WEB_VPC_GATEWAY_ID} \
--vpc-id ${WEB_VPC_ID}
```

VPCにアタッチされたことを確認する。

```bash
$ aws ec2 describe-internet-gateways \
--internet-gateway-id ${WEB_VPC_GATEWAY_ID} \
--query 'InternetGateways[]'
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
                "Value": "web-vpc-gateway"
            }
        ]
    }
]
```

## インターネットへのルートを追加

- メインルートテーブル
  - 他のルートテーブルに明示的に関連付けられていないすべてのサブネットのルーティングを制御する
    - VPCを作成するとメインルートテーブルが自動的に割り当てられる。
    - 作成されたルートテーブルには、VPC内のルーティングが既に設定されている。
- カスタムルートテーブル
  - VPC内の通信を保護するため、メインルートテーブルは変更しないことが推奨されている。
  - カスタムルートテーブルを追加し、デフォルトルートの宛先をインターネットゲートウェイにして、カスタムルートテーブルに追加する。
  - これによりVPC内部宛て以外の通信はすべてインターネットに送られることになる。言い換えると、**この設定をしないと、VPC内からインターネットへの通信はできない。**
- デフォルトルートとは
    - ルーティングのデフォルト設定。宛先がルートテーブルにない通信は、すべてデフォルトルートの宛先に送られる。

### メインルートテーブルが存在することを確認

```bash
$ aws ec2 describe-route-tables \
--filter "Name=vpc-id,Values=${WEB_VPC_ID}"
{
    "RouteTables": [
        {
            "Associations": [
                {
                    "Main": true,
                    "RouteTableAssociationId": "rtbassoc-03722b0f55c08cfb8",
                    "RouteTableId": "rtb-0553a9e980a66d7b2",
                    "AssociationState": {
                        "State": "associated"
                    }
                }
            ],
            "PropagatingVgws": [],
            "RouteTableId": "rtb-0553a9e980a66d7b2",
            "Routes": [
                {
                    "DestinationCidrBlock": "192.168.10.0/24",
                    "GatewayId": "local",
                    "Origin": "CreateRouteTable",
                    "State": "active"
                }
            ],
            "Tags": [],
            "VpcId": "vpc-06b8bc583831e40c6",
            "OwnerId": "937264738810"
        }
    ]
}
```

### カスタムルートテーブルを作成
```bash
$ aws ec2 create-route-table \
--vpc-id ${WEB_VPC_ID} \
--tag-specifications ResourceType=route-table,Tags="[{Key=Name,Value=web-vpc-route-table}]"
{
    "RouteTable": {
        "Associations": [],
        "PropagatingVgws": [],
        "RouteTableId": "rtb-0b59a183c11d8e40a",
        "Routes": [
            {
                "DestinationCidrBlock": "192.168.10.0/24",
                "GatewayId": "local",
                "Origin": "CreateRouteTable",
                "State": "active"
            }
        ],
        "Tags": [
            {
                "Key": "Name",
                "Value": "web-vpc-route-table"
            }
        ],
        "VpcId": "vpc-06b8bc583831e40c6",
        "OwnerId": "937264738810"
    }
}
```
#### カスタムルートテーブルIDを環境変数に設定

`~/set_variables_day_02.sh`に追加する。
```bash
$ echo "export WEB_VPC_ROUTE_TABLE_ID="`aws ec2 describe-route-tables \
--filters Name=tag:Name,Values="web-vpc-route-table" \
--query "RouteTables[].RouteTableId" \
--output text` >> ~/set_variables_day_02.sh
$ . ~/set_variables_day_02.sh 
$ echo $WEB_VPC_ROUTE_TABLE_ID
rtb-0b59a183c11d8e40a
```
### カスタムルートテーブルにルーティングルールを追加

カスタムルートテーブルにデフォルトルート`0.0.0.0/0`を追加する。

```bash
$ aws ec2 create-route \
--route-table-id ${WEB_VPC_ROUTE_TABLE_ID} \
--destination-cidr-block "0.0.0.0/0" \
--gateway-id ${WEB_VPC_GATEWAY_ID}
{
    "Return": true
}
```

ルーティングテーブルにデフォルトルートが追加されたことを確認する。

```bash
$ aws ec2 describe-route-tables \
--filter "Name=route-table-id,Values=${WEB_VPC_ROUTE_TABLE_ID}" \
--query "RouteTables[].Routes[]"
[
    {
        "DestinationCidrBlock": "192.168.10.0/24",
        "GatewayId": "local",
        "Origin": "CreateRouteTable",
        "State": "active"
    },
    {
        "DestinationCidrBlock": "0.0.0.0/0",
        "GatewayId": "igw-048bc8e258c0f4449",
        "Origin": "CreateRoute",
        "State": "active"
    }
]
```

### カスタムルートテーブルをサブネットに関連付ける
```bash
$ aws ec2 associate-route-table \
--subnet-id ${WEB_VPC_SUBNET_ID} \
--route-table-id ${WEB_VPC_ROUTE_TABLE_ID}
{
    "AssociationId": "rtbassoc-0f4a609f6737758a2",
    "AssociationState": {
        "State": "associated"
    }
}
```

カスタムルートテーブルとサブネットが関連付けられたことを確認する。

```bash
$ aws ec2 describe-route-tables \
--filter "Name=vpc-id,Values=${WEB_VPC_ID}"
{
    "RouteTables": [
        {
            "Associations": [
                {
                    "Main": false,
                    "RouteTableAssociationId": "rtbassoc-0f4a609f6737758a2",
                    "RouteTableId": "rtb-0b59a183c11d8e40a",
                    "SubnetId": "subnet-04c0bfe45bd9a529f",
                    "AssociationState": {
                        "State": "associated"
                    }
                }
            ],
            "PropagatingVgws": [],
            "RouteTableId": "rtb-0b59a183c11d8e40a",
            "Routes": [
                {
                    "DestinationCidrBlock": "192.168.10.0/24",
                    "GatewayId": "local",
                    "Origin": "CreateRouteTable",
                    "State": "active"
                },
                {
                    "DestinationCidrBlock": "0.0.0.0/0",
                    "GatewayId": "igw-048bc8e258c0f4449",
                    "Origin": "CreateRoute",
                    "State": "active"
                }
            ],
            "Tags": [
                {
                    "Key": "Name",
                    "Value": "web-vpc-route-table"
                }
            ],
            "VpcId": "vpc-06b8bc583831e40c6",
            "OwnerId": "937264738810"
        },
        {
            "Associations": [
                {
                    "Main": true,
                    "RouteTableAssociationId": "rtbassoc-03722b0f55c08cfb8",
                    "RouteTableId": "rtb-0553a9e980a66d7b2",
                    "AssociationState": {
                        "State": "associated"
                    }
                }
            ],
            "PropagatingVgws": [],
            "RouteTableId": "rtb-0553a9e980a66d7b2",
            "Routes": [
                {
                    "DestinationCidrBlock": "192.168.10.0/24",
                    "GatewayId": "local",
                    "Origin": "CreateRouteTable",
                    "State": "active"
                }
            ],
            "Tags": [],
            "VpcId": "vpc-06b8bc583831e40c6",
            "OwnerId": "937264738810"
        }
    ]
}
```

## 参考

- [Amazon VPC オプションを有効化してプライベートホストゾーンを使用する](https://aws.amazon.com/jp/premiumsupport/knowledge-center/vpc-enable-private-hosted-zone/)
- [VPC での DNS の使用 - Amazon Virtual Private Cloud](https://docs.aws.amazon.com/ja_jp/vpc/latest/userguide/vpc-dns.html)