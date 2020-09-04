# オブジェクトのライフサイクル管理

###### tags: `cetc`,`day01`

# ゴール

# 想定するワークロード
S3を介して、システム間をデータ連携する。

# 前提
環境変数が設定されていること。

```bash=+
echo $S3_BUCKET_NAME
www.jhashimoto.soft-think.com
```

バケットが存在すること

オブジェクトアップロード
=

ライフサイクルポリシーを作成する
=

**.lifecycle_policy.json**
```bash=
{
    "Rules": [
        {
            "ID": "id-1",
            "Filter": {
                "And": {
                    "Prefix": "myprefix", 
                    "Tags": [
                        {
                            "Value": "mytagvalue1", 
                            "Key": "mytagkey1"
                        }, 
                        {
                            "Value": "mytagvalue2", 
                            "Key": "mytagkey2"
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

ライフサイクルポリシーを適用する
=

```bash=
$ aws s3api put-bucket-lifecycle-configuration \
--bucket bucketname \
--lifecycle-configuration file://lifecycle.json
```

ライフサイクルポリシーを確認する。

```bash=
$ aws s3api get-bucket-lifecycle-configuration \
--bucket bucketname  
```

ヘッダ確認
=

```bash=
$ aws s3api head-object \
--bucket $S3_BUCKET_NAME \
--key welcome.html
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


テスト
=

# 特定のオブジェクトにのみライフサイクルポリシーを適用するには？
タグが付けられたオブジェクトのみをライフサイクルポリシーの対象にすることができる。

## タグを付ける
=

```bash=+
aws s3api put-object-tagging \
--bucket my-bucket \
--key doc1.rtf \
--tagging '{"TagSet": [{ "Key": "managed_lifecycle_policy", "Value": "true" }]}'
```

## ポリシー設定例


# 補足資料

# 参考

---
テンプレート

## 
```bash=

```
