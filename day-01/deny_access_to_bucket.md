###### tags: `cetc`,`day01`
# バケットへの他のユーザーのアクセスを拒否する

## ゴール
バケットにバケットポリシーを適用し、自分以外のIAMユーザーのアクセスを拒否する。

### バケットポリシーとは
IAMポリシーには、S3リソース（バケット、オブジェクト）に対するアクセス許可を付与する機能がある。これをバケットポリシーと呼ぶ。

## 前提
IAMユーザーを用意する。

- allowed_user この実習で使用しているユーザー。バケットへの参照を許可する。
- denied_user　バケットへの参照を拒否するユーザー。他にユーザーがなければ新たに作成する。

denied_userでマネジメントコンソールにログインし、バケットを参照できることを確認する。

## バケットポリシー定義ファイルを作成する
```bash=
$ vim www_bucket_policy.json
```
### www_bucket_policy.json

```json=
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "{USER_ARN}"
            },
            "Action": "s3:*",
            "Resource": [
                "{BUCKET_ARN}"
            ]
        },
        {
            "Effect": "Deny",
            "Principal": "*",
            "NotAction": "s3:GetObject",
            "Resource": [
                "{BUCKET_ARN}"
            ],
            "Condition": {
                "StringNotEquals": {
                    "aws:username": "{USER_NAME}"
                }
            }
        }
    ]
}
```

#### 環境依存
| プレイスホルダー | 意味 | 例 |
| -------- | -------- | -------- |
| {USER_ARN}     | バケットへのアクセスを許可するIAMユーザーのARN  | arn:aws:iam::1234567890:user/jhashimoto |
| {BUCKET_ARN}     | バケット名 | arn:aws:s3:::www.jhashimoto.soft-think.com  |
| {USER_NAME}     | バケットへのアクセスを許可するIAMユーザーの名前     | jhashimoto |

#### 設定例
```json=
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::1234567890:user/jhashimoto"
            },
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::www.jhashimoto.soft-think.com"
            ]
        },
        {
            "Effect": "Deny",
            "Principal": "*",
            "NotAction": "s3:GetObject",
            "Resource": [
                "arn:aws:s3:::www.jhashimoto.soft-think.com"
            ],
            "Condition": {
                "StringNotEquals": {
                    "aws:username": "jhashimoto"
                }
            }
        }
    ]
}
```

## バケットポリシーをバケットに適用する
```bash=+
$ aws s3api put-bucket-policy --bucket $S3_BUCKET_NAME --policy file://www_bucket_policy.json
```

## テスト
- allowed_userで、バケットにアクセスできること
- denied_userで、バケットにアクセスできないこと

### トラブルシュート
バケットポリシーの記述を誤って、全てのIAMユーザーに対してアクセス拒否を設定してしまった場合は、バケットポリシーの変更ができなくなる。

この場合は、ルートアカウントでログインするとバケットポリシーを変更できる。

## S3リソースのアクセス管理
[20190220 AWS Black Belt Online Seminar Amazon S3 / Glacier](https://www.slideshare.net/AmazonWebServicesJapan/20190220-aws-black-belt-online-seminar-amazon-s3-glacier)
- P.23
