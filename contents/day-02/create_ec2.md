# Webサーバー用EC2インスタンスを作成する

## ステップ

1. セキュリティグループの作成
2. インスタンスの作成
3. インスタンスにリモート接続する

## 前提

前項の環境変数が設定されていること。ログアウトした場合は、再度読み込む。

```bash
$ . ~/set_variables_day_02.sh 
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

ローカルPCのグローバルIPアドレスを環境変数に設定する（グローバルIPアドレスは変更されるので`set_variables_day_02.sh`には設定しない）。
```bash
$ export CLIENT_GLOBAL_IP=xxx.xxx.xxx.xxx
```

インスタンスに設定するセキュリティグループを作成する。

```bash
$ echo "export WEB_SG_ID=`aws ec2 create-security-group \
--group-name \"cetc-web-sg\" \
--description=\"this sg is for web server in cetc.\" \
--vpc-id=${WEB_VPC_ID} \
--output text`" >> ~/set_variables_day_02.sh
$ . ~/set_variables_day_02.sh
$ echo ${WEB_SG_ID}
sg-0d1e1f0ce929e34ab
```

許可する通信を設定する。

| プロトコル | 通信元     |
| ---------- | ---------- |
| SSH        | ローカルPC |
| HTTP       | 制限なし   |

```bash
$ aws ec2 authorize-security-group-ingress \
--group-id ${WEB_SG_ID} \
--protocol tcp \
--port 22 \
--cidr ${CLIENT_GLOBAL_IP}/32
$ aws ec2 authorize-security-group-ingress \
--group-id ${WEB_SG_ID} \
--protocol tcp \
--port 80 \
--cidr 0.0.0.0/0
```

設定を確認する。

```bash
$ aws ec2 describe-security-groups \
--group-id ${WEB_SG_ID}
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
キーペアを作成する。今回は`cetc`が作成済みなので不要。

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
| パブリックIPアドレス関連付け | 有効 |
| 削除保護             | 有効               |

```bash
$ aws ec2 run-instances \
--image-id ami-0cc75a8978fbbc969 \
--subnet-id ${WEB_VPC_SUBNET_ID} \
--security-group-ids ${WEB_SG_ID} \
--instance-type t2.micro \
--key-name cetc \
--associate-public-ip-address \
--disable-api-termination \
--tag-specifications ResourceType=instance,Tags="[{Key=Name,Value=cetc-web-server}]"
{
    "Groups": [],
    "Instances": [
        {
            "AmiLaunchIndex": 0,
            "ImageId": "ami-0cc75a8978fbbc969",
...
        }
    ],
    "OwnerId": "937264738810",
    "ReservationId": "r-077a32bb205e41b79"
}
```

### インスタンスIDを環境変数に設定

```bash
$ echo "export WEB_EC2_INSTANCE_ID=`aws ec2 describe-instances \
--filters Name=tag:Name,Values="cetc-web-server" \
--query 'Reservations[].Instances[].InstanceId' \
--output text`" >> ~/set_variables_day_02.sh
$ . ~/set_variables_day_02.sh
$ echo $WEB_EC2_INSTANCE_ID
```

### インスタンス作成完了の確認

`watch`コマンドで`State`が`running`になるのを待つ。

```bash
$ watch -d aws ec2 describe-instances \
--instance-ids $WEB_EC2_INSTANCE_ID \
--query 'Reservations[].Instances[].[State][].[Name]'
Every 2.0s: aws ec2 describe-instances \
--instance-ids i-0a3eaa77c3fe8ceb5 \
--query Reservations[].Instances[].[State][].[Name]                                                                                   Wed Sep 16 01:13:16 2020
[
    [
        "pending"
    ]
]
...
Every 2.0s: aws ec2 describe-instances \
--instance-ids i-0a3eaa77c3fe8ceb5 \
--query Reservations[].Instances[].[State][].[Name]                                                                                   Wed Sep 16 01:14:00 2020
[
    [
        "running"
    ]
]
```
- `watch`コマンドのtips
    - `-d`を付けると、出力が前回と変わったときにハイライトされるので、変更に気付きやすい
    - `Ctrl` + `C`で終了

### Webサーバー用インスタンスにリモート接続する

インスタンスに割り当てられたグローバルIPアドレスを調べる。

```bash
$ aws ec2 describe-instances \
--instance-ids $WEB_EC2_INSTANCE_ID \
--query 'Reservations[].Instances[].PublicIpAddress' \
--output text
18.183.224.31
```

ローカルPCから別のターミナルを起動し、SSHでログインできることを確認する。
```bash
$ ssh -i ~/keypair/cetc.pem ec2-user@18.183.224.31
load pubkey "/c/Users/Junichi/keypair/cetc.pem": invalid format
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
### CLIでAMIを検索する

マネジメントコンソールでもAMIを検索できるが、ワイルドカードが使えない。ワイルドカードで検索したいときは、CLIを使う。

CentOS 8.2のAMIを検索する例。

AWS公式のAMIを検索する。
```bash=+
$ aws ec2 describe-images \
--owners amazon \
--filters 'Name=name,Values=CentOS 8.2*' 'Name=architecture,Values=x86_64'
{
    "Images": []
}
```
AWS公式以外で探してみる。
```bash=
$ aws ec2 describe-images \
--owner aws-marketplace \
--filters 'Name=name,Values=CentOS?8.2*' 'Name=architecture,Values=x86_64' \
--query 'reverse(sort_by(Images, &CreationDate))[0]'
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

### CLIでキーペアを作成する
キーペアを作成。

```bash
$ aws ec2 create-key-pair \
--key-name foo \
--query 'KeyMaterial' \
--output text > foo.pem
$ cat foo.pem 
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEAhEDv3...
...
...C1pg5HyC86QCdsC3jd
-----END RSA PRIVATE KEY-----
```

この秘密鍵でインスタンスにSSH接続すると、`Permissions 0644 for 'foo.pem' are too open.`のエラーが発生する。

```bash=
$ ssh -i foo.pem ec2-user@54.250.173.180
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@         WARNING: UNPROTECTED PRIVATE KEY FILE!          @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
Permissions 0644 for 'foo.pem' are too open.
It is required that your private key files are NOT accessible by others.
This private key will be ignored.
Load key "foo.pem": bad permissions
ec2-user@54.250.173.180: Permission denied (publickey,gssapi-keyex,gssapi-with-mic).
```

権限を確認する。

```bash
$ ls -l foo.pem 
-rw-r--r--. 1 root root 1671  6月 21 07:55 foo.pem
```

秘密鍵の所有者以外に書き込み権限があるため。

所有者以外の権限を除去すると、SSHで接続できるようになる。
```bash
$ chmod 600 foo.pem 
$ ls -l foo.pem 
-rw-------. 1 root root 1671  6月 21 07:55 foo.pem
```
