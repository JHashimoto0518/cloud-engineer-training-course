# バケットへの他のユーザーのアクセスを拒否する

## ゴール
バケットにバケットポリシーを適用し、自分以外のIAMユーザーのアクセスを拒否する。

## ステップ
1. バケットポリシー定義ファイルを作成する
2. バケットポリシーをバケットに適用する

## 用語
この手順では、次の用語を使用する。

| 用語 | 意味 | 備考 |
| -------- | -------- | -------- |
| allowed_user     | バケットへのアクセスを許可するユーザー     | この実習で使用しているユーザー     |
| denied_user     | バケットへのアクセスを許可しないユーザー    | なければ新たに作成する     |

## 前提

- 環境変数が設定されていること。
```bash+=
$ echo $S3_ETL_BUCKET_NAME
etl.jhashimoto.soft-think.com
```
- バケットが存在すること。
```bash=+
$ aws s3 ls | grep etl
2020-09-04 23:24:18 etl.jhashimoto.soft-think.com
```
- IAMでallowed_userとdenied_userが作成されていること。
- denied_userでマネジメントコンソールにログインし、バケットとオブジェクトを参照できること。

## バケットポリシー定義ファイルを作成する
**etl_bucket_policy.json**

| プレイスホルダー | 意味 | 例 |
| -------- | -------- | -------- |
| {USER_ARN}     | allowed_userのARN  | arn:aws:iam::1234567890:user/jhashimoto |
| {BUCKET_NAME}     | バケット名 | etl.jhashimoto.soft-think.com  |
| {USER_NAME}     | allowed_userの名前     | jhashimoto |

ARN
:    [Amazon リソースネーム \(ARN\) \- AWS 全般のリファレンス](https://docs.aws.amazon.com/ja_jp/general/latest/gr/aws-arns-and-namespaces.html)
    > Amazon リソースネーム (ARN) は、AWS リソースを一意に識別します。全 AWS に渡るリソースを指定する必要がある場合、ARN が必要です。

*[ARN]: Amazon Resource Name 

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
                "arn:aws:s3:::{BUCKET_NAME}",
                "arn:aws:s3:::{BUCKET_NAME}/*"
            ]
        },
        {
            "Effect": "Deny",
            "Principal": "*",
            "NotAction": "s3:GetObject",
            "Resource": [
                "arn:aws:s3:::{BUCKET_NAME}",
                "arn:aws:s3:::{BUCKET_NAME}/*"
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

## バケットポリシーをバケットに適用する
```bash=+
$ aws s3api put-bucket-policy \
--bucket $S3_ETL_BUCKET_NAME \
--policy file://etl_bucket_policy.json

```

## テスト
- allowed_userで、バケットにアクセスできること
- denied_userで、バケットにアクセスできないこと

### トラブルシュート
バケットポリシーの記述を誤って、全てのIAMユーザーに対してアクセス拒否を設定してしまった場合は、バケットポリシーの変更ができなくなる。

この場合は、ルートアカウントでログインするとバケットポリシーを変更できる。
