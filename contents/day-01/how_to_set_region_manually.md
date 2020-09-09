# デフォルトリージョンの設定

imds経由でリージョンが設定されないケースがある。
- AWS CLI v1を使用している
- 実行環境がEC2インスタンスではない

この場合は、手動でデフォルトリージョンを設定できる。

## デフォルトリージョンの設定がない場合

リージョンサービス[^region_service]のコマンドを実行すると、エラーメッセージが出力される。

```bash=+
$ aws ec2 describe-vpcs
You must specify a region. You can also configure your region by running "aws configure".
```

[^region_service]:
    リージョンごとに作成、管理するサービス。これに対してリージョンを指定する必要のないサービスをグローバルサービスと言う。例えばIAMはグローバルサービス。

実行するには、コマンド実行時に`region`パラメータ指定が必要。
```bash=+
$ aws ec2 describe-vpcs --region ap-northeast-1
{
    "Vpcs": [
        {
            "CidrBlock": "172.31.0.0/16",
            "DhcpOptionsId": "dopt-224b1145",
            "State": "available",
            "VpcId": "vpc-be4a76d9",
            "OwnerId": "937264738810",
            "InstanceTenancy": "default",
            "CidrBlockAssociationSet": [
                {
                    "AssociationId": "vpc-cidr-assoc-abd5ecc3",
                    "CidrBlock": "172.31.0.0/16",
                    "CidrBlockState": {
                        "State": "associated"
                    }
                }
            ],
            "IsDefault": true
        }
    ]
}
```

## デフォルトリージョンの設定

リージョン指定なしでコマンドを実行可能にするには、デフォルトのリージョンを設定する必要がある。いくつか方法がある。

Profile[^profile]に設定する例。

[^profile]:
    [名前付きプロファイル \- AWS Command Line Interface](https://docs.aws.amazon.com/ja_jp/cli/latest/userguide/cli-configure-profiles.html)

```bash=
$ aws configure set profile.jhashimoto.region ap-northeast-1
$ aws configure list --profile jhashimoto
      Name                    Value             Type    Location
      ----                    -----             ----    --------
   profile               jhashimoto           manual    --profile
access_key     ****************HWUZ shared-credentials-file
secret_key     ****************CbaT shared-credentials-file
    region           ap-northeast-1      config-file    ~/.aws/config
```

環境変数を使用する例。`~/.bashrc`で設定する。

```bash=
export AWS_DEFAULT_REGION=ap-northeast-1
```

リージョン指定なしで、コマンド実行できるようになった。
```bash=+
$ aws ec2 describe-vpcs
{
    "Vpcs": [
        {
...
        }
    ]
}
```
