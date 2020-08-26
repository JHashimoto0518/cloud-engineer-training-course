###### tags: `cetc`,`day01`
# バケットへの他のユーザーのアクセスを拒否する

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
                "{BUCKET_ARN}",
                "{BUCKET_ARN}/*"
            ]
        },
        {
            "Effect": "Deny",
            "Principal": "*",
            "NotAction": "s3:GetObject",
            "Resource": [
                "{BUCKET_ARN}",
                "{BUCKET_ARN}/*"
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
| {USER_ARN}     | バケットへのアクセスを許可するIAMユーザーのARN  | arn:aws:iam::773217231744:user/jhashimoto |
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
                "AWS": "arn:aws:iam::773217231744:user/jhashimoto"
            },
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::www.jhashimoto.soft-think.com",
                "arn:aws:s3:::www.jhashimoto.soft-think.com/*"
            ]
        },
        {
            "Effect": "Deny",
            "Principal": "*",
            "NotAction": "s3:GetObject",
            "Resource": [
                "arn:aws:s3:::www.jhashimoto.soft-think.com",
                "arn:aws:s3:::www.jhashimoto.soft-think.com/*"
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
バケットへのアクセスを許可したIAMユーザー以外で、バケットにアクセスできないことを確認する。マネジメントコンソールでもCLIでもよい。

## トラブルシュート
バケットポリシーの記述を誤って、許可すべきIAMユーザーに対してアクセス拒否を設定してしまった場合は、権限がないのでバケットポリシーの変更もできなくなる。

この場合は、ルートアカウントでログインするとバケットポリシーを変更できる。
