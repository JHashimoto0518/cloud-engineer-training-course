# Webサーバー用EC2インスタンスを作成する

## ステップ

1. セキュリティグループ作成
2. インスタンス作成

# 前提

- VPC構築の環境変数が設定されていること

# 環境変数の設定
TODO:

```bash
$ vim set_variables.sh
```
USER_IDは、.bashrcに定義済みの前提。

**set_variables.sh**
```bash
#!/bin/bash

export AMI_ID="ami-"
export EC2_SG_GID="sg-"
export EC2_INS_1_ID="i-"
export EC2_INS_1_PUB_IP="???"
export SUBNET_1_ID="subnet-???"
export SUBNET_2_ID="subnet-???"
```

## 読み込む
```bash+=
$ . set_variables.sh 
```

環境変数が設定されていること。

```bash
echo $S3_BUCKET_NAME
www.jhashimoto.soft-think.com
```

## ローカルPCのグローバルIPアドレスを確認

`cetc_cli_server`にログインする前に、クライアントからの通信に使用されているグローバルIPアドレスを確認しておく。

```bash
$ curl inet-ip.info/ip
xxx.xxx.xxx.xxx
```

以降の作業は、`cetc_cli_server`にログインして行う。

## リソース作成
インスタンスに必要なリソースを作成する。

### セキュリティグループを作成

| 属性       | 値                 | 意味     |
| ---------- | ------------------ | ---- |
| リソース名 | cetc-web-sg |      |
| VPC        | web-vpc            | どのVPCに属するか  |

ローカルPCのグローバルIPアドレスを環境変数に設定しておく。
```bash
$ export CLIENT_GLOBAL_IP=xxx.xxx.xxx.xxx
```

インスタンスに設定するセキュリティグループを作成する。

```bash
[ec2-user@ip-172-31-37-34 ~]$ echo "export WEB_SG_ID=`aws ec2 create-security-group --group-name \"cetc-web-sg\" --description=\"this sg is for web server in cetc.\" --vpc-id=${WEB_VPC_ID} --output text`" >> ~/.bashrc 
[ec2-user@ip-172-31-37-34 ~]$ . ~/.bashrc 
[ec2-user@ip-172-31-37-34 ~]$ echo ${WEB_SG_ID} 
sg-0d1e1f0ce929e34ab
```

許可する通信を設定する。

| プロトコル | 通信元     |
| ---------- | ---------- |
| SSH        | ローカルPC |
| HTTP       | 制限なし   |

```bash
$ aws ec2 authorize-security-group-ingress --group-id ${WEB_SG_ID} --protocol tcp --port 22 --cidr ${CLIENT_GLOBAL_IP}/32
$ aws ec2 authorize-security-group-ingress --group-id ${WEB_SG_ID} --protocol tcp --port 80 --cidr 0.0.0.0/0
```

設定を確認する。

```bash
$ [ec2-user@ip-172-31-37-34 ~]$ aws ec2 describe-security-groups --group-id ${WEB_SG_ID}
{
    "SecurityGroups": [
        {
            "Description": "this sg is for web server in cetc.",
            "GroupName": "cetc-web-sg",
            "IpPermissions": [
                {
                    "FromPort": 80,
                    "IpProtocol": "tcp",
                    "IpRanges": [
                        {
                            "CidrIp": "0.0.0.0/0"
                        }
                    ],
                    "Ipv6Ranges": [],
                    "PrefixListIds": [],
                    "ToPort": 80,
                    "UserIdGroupPairs": []
                },
                {
                    "FromPort": 22,
                    "IpProtocol": "tcp",
                    "IpRanges": [
                        {
                            "CidrIp": "3.112.243.141/32"
                        }
                    ],
                    "Ipv6Ranges": [],
                    "PrefixListIds": [],
                    "ToPort": 22,
                    "UserIdGroupPairs": []
                }
            ],
            "OwnerId": "937264738810",
            "GroupId": "sg-0d1e1f0ce929e34ab",
            "IpPermissionsEgress": [
                {
                    "IpProtocol": "-1",
                    "IpRanges": [
                        {
                            "CidrIp": "0.0.0.0/0"
                        }
                    ],
                    "Ipv6Ranges": [],
                    "PrefixListIds": [],
                    "UserIdGroupPairs": []
                }
            ],
            "VpcId": "vpc-06b8bc583831e40c6"
        }
    ]
}
```

### キーペアの作成
キーペアを作成する。今回は作成済みなので不要。

## Webサーバー用インスタンスの作成

インスタンスを作成する。

| 属性                 | 値                 |
| -------------------- | ------------------ |
| リソース名           | cetc-web-server    |
| AMI                  | Amazon Linux 2     |
| サブネット           | web-vpc-subnet     |
| セキュリティグループ | cetc-web-sg |
| インスタンスタイプ   | t2.micro           |
| キーペア             | cetc               |
| 削除保護             | 有効               |


```bash=
$ aws ec2 run-instances --image-id ami-0cc75a8978fbbc969 --subnet-id ${WEB_VPC_SUBNET_ID} --security-group-ids ${WEB_SG_ID} --instance-type t2.micro --key-name cetc --disable-api-termination  --tag-specifications ResourceType=instance,Tags="[{Key=Name,Value=cetc-web-server}]"
{
    "Groups": [],
    "Instances": [
        {
            "AmiLaunchIndex": 0,
            "ImageId": "ami-0cc75a8978fbbc969",
            "InstanceId": "i-0a3eaa77c3fe8ceb5",
            "InstanceType": "t2.micro",
            "KeyName": "cetc2",
            "LaunchTime": "2020-09-16T01:00:27+00:00",
            "Monitoring": {
                "State": "disabled"
            },
            "Placement": {
                "AvailabilityZone": "ap-northeast-1a",
                "GroupName": "",
                "Tenancy": "default"
            },
            "PrivateDnsName": "ip-192-168-10-126.ap-northeast-1.compute.internal",
            "PrivateIpAddress": "192.168.10.126",
            "ProductCodes": [],
            "PublicDnsName": "",
            "State": {
                "Code": 0,
                "Name": "pending"
            },
            "StateTransitionReason": "",
            "SubnetId": "subnet-04c0bfe45bd9a529f",
            "VpcId": "vpc-06b8bc583831e40c6",
            "Architecture": "x86_64",
            "BlockDeviceMappings": [],
            "ClientToken": "6a8fb9bf-4bd4-4116-bec5-96139adf22a3",
            "EbsOptimized": false,
            "Hypervisor": "xen",
            "NetworkInterfaces": [
                {
                    "Attachment": {
                        "AttachTime": "2020-09-16T01:00:27+00:00",
                        "AttachmentId": "eni-attach-08c96e7fccc2a9e2a",
                        "DeleteOnTermination": true,
                        "DeviceIndex": 0,
                        "Status": "attaching"
                    },
                    "Description": "",
                    "Groups": [
                        {
                            "GroupName": "cetc-web-sg",
                            "GroupId": "sg-0d1e1f0ce929e34ab"
                        }
                    ],
                    "Ipv6Addresses": [],
                    "MacAddress": "06:68:ed:c4:ac:1e",
                    "NetworkInterfaceId": "eni-05585173825768c8e",
                    "OwnerId": "937264738810",
                    "PrivateIpAddress": "192.168.10.126",
                    "PrivateIpAddresses": [
                        {
                            "Primary": true,
                            "PrivateIpAddress": "192.168.10.126"
                        }
                    ],
                    "SourceDestCheck": true,
                    "Status": "in-use",
                    "SubnetId": "subnet-04c0bfe45bd9a529f",
                    "VpcId": "vpc-06b8bc583831e40c6",
                    "InterfaceType": "interface"
                }
            ],
            "RootDeviceName": "/dev/xvda",
            "RootDeviceType": "ebs",
            "SecurityGroups": [
                {
                    "GroupName": "cetc-web-sg",
                    "GroupId": "sg-0d1e1f0ce929e34ab"
                }
            ],
            "SourceDestCheck": true,
            "StateReason": {
                "Code": "pending",
                "Message": "pending"
            },
            "Tags": [
                {
                    "Key": "Name",
                    "Value": "cetc-web-server"
                }
            ],
            "VirtualizationType": "hvm",
            "CpuOptions": {
                "CoreCount": 1,
                "ThreadsPerCore": 1
            },
            "CapacityReservationSpecification": {
                "CapacityReservationPreference": "open"
            },
            "MetadataOptions": {
                "State": "pending",
                "HttpTokens": "optional",
                "HttpPutResponseHopLimit": 1,
                "HttpEndpoint": "enabled"
            }
        }
    ],
    "OwnerId": "937264738810",
    "ReservationId": "r-077a32bb205e41b79"
}
```

### インスタンスIDを環境変数に設定

```bash
$ echo "export WEB_EC2_INSTANCE_ID=`aws ec2 run-instances --image-id ami-0cc75a8978fbbc969 --subnet-id ${WEB_VPC_SUBNET_ID} --security-group-ids ${WEB_SG_ID} --instance-type t2.micro --key-name cetc2 --disable-api-termination --tag-specifications ResourceType=instance,Tags="[{Key=Name,Value=cetc-web-server}]" --output text`" >> ~/.bashrc
$ . ~/.bashrc
$ echo $WEB_EC2_INSTANCE_ID
i-0a3eaa77c3fe8ceb5
```

### インスタンス作成完了の確認
`watch`コマンドで`State`が`running`になるのを待つ。

```bash
$ watch -d aws ec2 describe-instances --instance-ids $WEB_EC2_INSTANCE_ID --query 'Reservations[].Instances[].[State][].[Name]'
Every 2.0s: aws ec2 describe-instances --instance-ids i-0a3eaa77c3fe8ceb5 --query Reservations[].Instances[].[State][].[Name]                                                                                   Wed Sep 16 01:13:16 2020
[
    [
        "pending"
    ]
]
...
Every 2.0s: aws ec2 describe-instances --instance-ids i-0a3eaa77c3fe8ceb5 --query Reservations[].Instances[].[State][].[Name]                                                                                   Wed Sep 16 01:14:00 2020
[
    [
        "running"
    ]
]
```
- `watch`コマンドのtips
    - `-d`を付けると、出力が前回と変わったときにハイライトされるので、変更に気付きやすい
    - `Ctrl` + `C`で終了

### Web serverにリモート接続する

インスタンスに割り当てられたグローバルIPアドレスを調べる。

```bash
$ aws ec2 describe-instances --instance-ids $WEB_EC2_INSTANCE_ID --query 'Reservations[].Instances[].PublicIpAddress' --output text
18.183.224.31
```

SSHでログインできることを確認する
```bash
$ ssh -i ~/keypair/cetc2.pem ec2-user@18.183.224.31
load pubkey "/c/Users/Junichi/keypair/cetc2.pem": invalid format
The authenticity of host '18.183.224.31 (18.183.224.31)' can't be established.
ECDSA key fingerprint is SHA256:0xhuwWP50K9qJMk4k4EyaoZSGsSzy2ZhIqrczPlqxYI.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '18.183.224.31' (ECDSA) to the list of known hosts.

       __|  __|_  )
       _|  (     /   Amazon Linux 2 AMI
      ___|\___|___|

https://aws.amazon.com/amazon-linux-2/
7 package(s) needed for security, out of 14 available
Run "sudo yum update" to apply all updates.
```

## 参考
### 参考: CLIで検索する
CLIは検索条件にワイルドカードが使えるので、検索漏れがない。

1. AWS公式のAMIは用意されていない
    ```bash=+
    $ aws ec2 describe-images --owners amazon --filters 'Name=name,Values=CentOS 8.2*' 'Name=architecture,Values=x86_64'
    {
        "Images": []
    }
    ```
2. AWS公式以外で探してみる
    ```bash=
    $ aws ec2 describe-images --owner aws-marketplace --filters 'Name=name,Values=CentOS?8.2*' 'Name=architecture,Values=x86_64' --query 'reverse(sort_by(Images, &CreationDate))[0]'
    {
        "Architecture": "x86_64",
        "CreationDate": "2020-06-19T00:36:50.000Z",
        "ImageId": "ami-094c249bf673c51c7",
        "ImageLocation": "aws-marketplace/CentOS-8.2-x86_64-Minimal-8GiB-HVM-20200616_131752-84a857fb-30b1-429f-8e92-3065cf289a61-ami-07f124b85512cd8a5.4",
        "ImageType": "machine",
        "Public": true,
        "OwnerId": "679593333241",
        "PlatformDetails": "Linux/UNIX",
        "UsageOperation": "RunInstances",
        "ProductCodes": [
            {
                "ProductCodeId": "7uqbx3krarmxb8xtupqvzm9up",
                "ProductCodeType": "marketplace"
            }
        ],
        "State": "available",
        "BlockDeviceMappings": [
            {
                "DeviceName": "/dev/sda1",
                "Ebs": {
                    "DeleteOnTermination": true,
                    "SnapshotId": "snap-00d182c3936912858",
                    "VolumeSize": 8,
                    "VolumeType": "gp2",
                    "Encrypted": false
                }
            }
        ],
        "Description": "CentOS-8.2-x86_64-Minimal-8GiB-HVM-20200616_131752",
        "EnaSupport": true,
        "Hypervisor": "xen",
        "ImageOwnerAlias": "aws-marketplace",
        "Name": "CentOS-8.2-x86_64-Minimal-8GiB-HVM-20200616_131752-84a857fb-30b1-429f-8e92-3065cf289a61-ami-07f124b85512cd8a5.4",
        "RootDeviceName": "/dev/sda1",
        "RootDeviceType": "ebs",
        "VirtualizationType": "hvm"
    }
    ```

### SSH認証用のキーペアを作成する
1. キーペア作成
	```bash=+
	$ aws ec2 create-key-pair --key-name user???_http_key --query 'KeyMaterial' --output text > user???_http_key.pem
	$ cat user???_http_key.pem 
	-----BEGIN RSA PRIVATE KEY-----
	MIIEowIBAAKCAQEAhEDv3...
	...
	...C1pg5HyC86QCdsC3jd
	-----END RSA PRIVATE KEY-----
	```
1. 秘密鍵から所有者以外の権限を除去する
	```bash=+
	$ chmod 600 user???_http_key.pem 
	$ ls -l user???_http_key.pem 
	-rw-------. 1 root root 1671  6月 21 07:55 user???_http_key.pem
	```
	- 参考
		- 所有者以外に書き込み権限を与えると、SSH接続で`Permissions 0644 for 'user???_http_key.pem' are too open.`のエラーが発生するため。
			```bash=
			$ ssh -i user???_http_key.pem ec2-user@54.250.173.180
			@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
			@         WARNING: UNPROTECTED PRIVATE KEY FILE!          @
			@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
			Permissions 0644 for 'user???_http_key.pem' are too open.
			It is required that your private key files are NOT accessible by others.
			This private key will be ignored.
			Load key "user???_http_key.pem": bad permissions
			ec2-user@54.250.173.180: Permission denied (publickey,gssapi-keyex,gssapi-with-mic).
			```
		- Linuxのssh実習でのエラーも、おそらくこれが理由と思われる。



