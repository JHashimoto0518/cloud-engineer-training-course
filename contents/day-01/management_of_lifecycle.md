# オブジェクトのライフサイクル管理

###### tags: `cetc`,`day01`

## 想定するワークロード
- S3を介して、システム間をデータ連携する
    - システムAがS3にCSVをアップロードし、システムBはS3からCSVを取り込む
    - S3にアップロードしたCSVは、一定期間が経過したら削除する

## ステップ
1. ライフサイクルポリシー定義ファイルを作成する
2. ライフサイクルポリシーをバケットに適用する

## 環境変数を設定する

```bash+=
$ vim ~/.bashrc
```

**.bashrc**

末尾に追記する。
```bash=
export S3_ETL_BUCKET_NAME=etl.$ID.soft-think.com
```

```bash+=
$ . ~/.bashrc
$ echo $S3_ETL_BUCKET_NAME
etl.jhashimoto.soft-think.com
```

## バケットの作成
```bash=+
$ aws s3api create-bucket \
--bucket $S3_ETL_BUCKET_NAME \
--acl public-read \
--create-bucket-configuration LocationConstraint=ap-northeast-1
{
    "Location": "http://www.jhashimoto.soft-think.com.s3.amazonaws.com/"
}
$ aws s3 ls | grep etl
2020-09-04 22:14:55 etl.jhashimoto.soft-think.com
```

## オブジェクトアップロード
テスト用のファイルをアップロードする。

```bash=+
$ echo "foo" | aws s3 cp - s3://$S3_ETL_BUCKET_NAME/csv/data1.csv
$ echo "bar" | aws s3 cp - s3://$S3_ETL_BUCKET_NAME/csv/data2.csv
$ $ aws s3 ls s3://$S3_ETL_BUCKET_NAME/csv/
2020-09-04 22:35:08          4 data1.csv
2020-09-04 22:35:22          4 data2.csv
```

## ライフサイクルポリシー定義ファイルを作成する

**csv_expiration_policy.json**
```json=
{
    "Rules": [
        {
            "ID": "csv_expiration_rules",
            "Filter": {
                "Prefix": "csv/"
            },
            "Status": "Enabled", 
            "Expiration": {
                "Days": 1
            }
        }
    ]
}
```

## ライフサイクルポリシーを適用する

ライフサイクルポリシーを適用する前にオブジェクトのヘッダを確認しておく。

```bash=
$ aws s3api head-object \
--bucket $S3_ETL_BUCKET_NAME \
--key csv/data1.csv
{
    "AcceptRanges": "bytes",
    "LastModified": "2020-09-04T05:33:03+00:00",
    "ContentLength": 198,
    "ETag": "\"711a442b6d0606f34c2c8d61935de6ea\"",
    "VersionId": "CMuKW8wl48TZbzFGx86dvM2PJ8xU7gqS",
    "ContentType": "text/html",
    "Metadata": {}
}
```

ポリシーを適用する。
```bash=
$ aws s3api put-bucket-lifecycle-configuration \
--bucket $S3_ETL_BUCKET_NAME \
--lifecycle-configuration file://csv_expiration_policy.json
```

適用されたポリシーを確認する。

```bash=
$ aws s3api get-bucket-lifecycle-configuration \
--bucket $S3_ETL_BUCKET_NAME
{
    "Rules": [
        {
            "Expiration": {
                "Days": 1
            },
            "ID": "csv_expiration_rules",
            "Filter": {
                "Prefix": "csv/"
            },
            "Status": "Enabled"
        }
    ]
}
```

## オブジェクトの有効期限を確認する

ヘッダにExpiration属性が追加されている。

```bash=
$ aws s3api head-object \
--bucket $S3_ETL_BUCKET_NAME \
--key csv/data1.csv                 {
    "AcceptRanges": "bytes",
    "Expiration": "expiry-date=\"Sun, 06 Sep 2020 00:00:00 GMT\", rule-id=\"csv_expiration_rules\"",
    "LastModified": "2020-09-04T22:35:08+00:00",
    "ContentLength": 4,
    "ETag": "\"d3b07384d113edec49eaa6238ad5ff00\"",
    "ContentType": "binary/octet-stream",
    "Metadata": {}
}
```

## テスト
有効期限が切れたオブジェクトが削除されることを確認する。有効期限は翌々日の09:00（日本標準時）。

[ライフサイクル設定の要素 \- Amazon Simple Storage Service](https://docs.aws.amazon.com/ja_jp/AmazonS3/latest/dev/intro-lifecycle-rules.html#intro-lifecycle-rules-number-of-days)
> Amazon S3 は、ルールに指定された日数をオブジェクトの作成時間に加算し、得られた日時を翌日の午前 00:00 UTC (協定世界時) に丸めることで、時間を算出します。たとえば、あるオブジェクトが 2014 年 1 月 15 日午前 10 時 30 分 (UTC) に作成され、移行ルールに 3 日と指定した場合、オブジェクトの移行日は 2014 年 1 月 19 日 0 時 0 分 (UTC) となります。

## 特定のオブジェクトにのみライフサイクルポリシーを適用するには？
タグが付けられたオブジェクトのみを削除の対象にできる。

### タグを付ける

```bash=+
$ aws s3api put-object-tagging \
--bucket $S3_ETL_BUCKET_NAME \
--key csv/data3.csv \
--tagging '{"TagSet": [{ "Key": "deletion_on", "Value": "true" }]}'
$ aws s3api get-object-tagging \
--bucket $S3_ETL_BUCKET_NAME \
--key csv/data3.csv
{
    "TagSet": [
        {
            "Key": "deletion_on",
            "Value": "true"
        }
    ]
}
```

### ポリシー設定例

```json=
{
    "Rules": [
        {
            "ID": "csv_expiration_rules2",
            "Filter": {
                "And": {
                    "Prefix": "csv/", 
                    "Tags": [
                        {
                            "Key": "deletion_on",
                            "Value": "true"
                        }
                    ]
                }
            }, 
            "Status": "Enabled", 
            "Expiration": {
                "Days": 1
            }
        }
    ]
}
```

## ファイルをアーカイブするには？

### ポリシー設定例
30日後にS3 Glacierにオブジェクトを移動し、60日後に削除する。

S3 Glacierは、S3よりも安価だが、オブジェクトの取り出しに時間がかかる。頻繁にアクセスしないオブジェクトをアーカイブするのに利用する。

```json=
{
    "Rules": [
        {
            "ID": "csv_archive_rules",
            "Filter": {
                "Prefix": "csv/"
            },
            "Status": "Enabled",
            "Transitions": [
                {
                    "Days": 30,
                    "StorageClass": "GLACIER"
                }
            ],
            "Expiration": {
                "Days": 60
            }
        }
    ]
}
```
