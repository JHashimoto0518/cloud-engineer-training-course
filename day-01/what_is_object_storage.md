オブジェクトストレージとは
=

###### tags: `cetc`,`day01`

## データストアの種類
[20190220 AWS Black Belt Online Seminar Amazon S3 / Glacier P.11](https://www.slideshare.net/AmazonWebServicesJapan/20190220-aws-black-belt-online-seminar-amazon-s3-glacier)
![20190220-aws-black-belt-online-seminar-amazon-s3-glacier-11-638.jpg](https://image.slidesharecdn.com/20190220aws-blackbelts3glacier-190226063716/95/20190220-aws-black-belt-online-seminar-amazon-s3-glacier-11-638.jpg?cb=1551163101)

- データベース
    - 定型データを格納する。
        - 事前にデータの形式を決める。
- ストレージ
    - 非定型データを格納する。
        - データの形式は任意。
            - 画像ファイル、動画ファイル、データファイル...

## ストレージの種類
[20190220 AWS Black Belt Online Seminar Amazon S3 / Glacier P.12](https://www.slideshare.net/AmazonWebServicesJapan/20190220-aws-black-belt-online-seminar-amazon-s3-glacier)
![20190220-aws-black-belt-online-seminar-amazon-s3-glacier-12-638.jpg](https://image.slidesharecdn.com/20190220aws-blackbelts3glacier-190226063716/95/20190220-aws-black-belt-online-seminar-amazon-s3-glacier-12-638.jpg?cb=1551163101)

- ファイルストレージ
    - データをファイル単位で格納
    - 一般的なファイルサーバー
    - ネットワーク（LAN）に接続して利用するので、NAS と呼ばれる。
    - 構築が容易で、異なるOS間でファイル共用が可能。
- ブロックストレージ
    - データを固定長のブロック単位に分割して格納
    - ファイルストレージやオブジェクトストレージの基盤として使用されることが多い
- オブジェクトストレージ
    - 階層のないフラットな構造
    - key-value形式
        - オブジェクト名をキーとし、データと関連付けて管理
    - http/https
    - ノードを並列化した分散ストレージ。拡張性が高い。
    - クラウドでは一般的

*[NAS]:Nework Attached Storage 

## S3のフォルダの正体は？

マネジメントコンソールでフォルダを作成する。

CLIで作成されたオブジェクトを確認する。

```bash=+
$ aws s3 ls s3://$S3_BUCKET_NAME
                           PRE folder1/
2020-09-03 06:00:41        192 hello.html
2020-09-03 06:00:41        190 welcome.html
$ aws s3api list-objects --bucket $S3_BUCKET_NAME
{
    "Contents": [
        {
            "Key": "folder1/",
            "LastModified": "2020-09-05T02:50:19+00:00",
            "ETag": "\"d41d8cd98f00b204e9800998ecf8427e\"",
            "Size": 0,
            "StorageClass": "STANDARD",
            "Owner": {
                "DisplayName": "junichi_hashimoto_aws",
                "ID": "20ff705d5e99c4465b612241c5cb440bcfd650c6297ae85bb834c19548e1f0af"
            }
        },
        {
            "Key": "hello.html",
            "LastModified": "2020-09-03T06:00:41+00:00",
            "ETag": "\"1cf3b9f820576b8f8bd047a5d7afb5b3\"",
            "Size": 192,
            "StorageClass": "STANDARD",
            "Owner": {
                "DisplayName": "junichi_hashimoto_aws",
                "ID": "20ff705d5e99c4465b612241c5cb440bcfd650c6297ae85bb834c19548e1f0af"
            }
        },
...
    ]
}
```

CLIにフォルダを作成するコマンドはないが、作成できる。
```bash=+
$ touch empty.txt
$ ls -l | grep empty.txt
-rw-rw-r-- 1 ec2-user ec2-user    0 Sep  5 02:56 empty.txt
$ aws s3api put-object --bucket $S3_BUCKET_NAME --key "folder2/" --body empty.txt
{
    "ETag": "\"d41d8cd98f00b204e9800998ecf8427e\""
}
```

マネジメントコンソールでフォルダが作成されたことを確認する。


作成したフォルダに、ファイルをアップロードする。
```bash=+
$ echo "aaa" > data.txt
$ aws s3api put-object --bucket $S3_BUCKET_NAME --key "folder2/data.txt" --body data.txt
{
    "ETag": "\"5c9597f3c8245907ea71a89d9d39d08e\""
}

```

フォルダを作成せずに、ファイルをアップロードする。
```bash=+
[ec2-user@ip-172-31-37-34 ~]$ aws s3api put-object --bucket $S3_BUCKET_NAME --key "folder3/data.txt" --body data.txt 
{
    "ETag": "\"5c9597f3c8245907ea71a89d9d39d08e\""
}

```

作成されたオブジェクトを確認する。

```bash=+
$ aws s3api list-objects --bucket $S3_BUCKET_NAME
{
    "Contents": [
...    
        {
            "Key": "folder2/",
            "LastModified": "2020-09-05T02:57:01+00:00",
            "ETag": "\"d41d8cd98f00b204e9800998ecf8427e\"",
            "Size": 0,
            "StorageClass": "STANDARD",
            "Owner": {
                "DisplayName": "junichi_hashimoto_aws",
                "ID": "20ff705d5e99c4465b612241c5cb440bcfd650c6297ae85bb834c19548e1f0af"
            }
        },
        {
            "Key": "folder2/data.txt",
            "LastModified": "2020-09-05T03:49:24+00:00",
            "ETag": "\"5c9597f3c8245907ea71a89d9d39d08e\"",
            "Size": 4,
            "StorageClass": "STANDARD",
            "Owner": {
                "DisplayName": "junichi_hashimoto_aws",
                "ID": "20ff705d5e99c4465b612241c5cb440bcfd650c6297ae85bb834c19548e1f0af"
            }
        },
        {
            "Key": "folder3/data.txt",
            "LastModified": "2020-09-05T03:50:23+00:00",
            "ETag": "\"5c9597f3c8245907ea71a89d9d39d08e\"",
            "Size": 4,
            "StorageClass": "STANDARD",
            "Owner": {
                "DisplayName": "junichi_hashimoto_aws",
                "ID": "20ff705d5e99c4465b612241c5cb440bcfd650c6297ae85bb834c19548e1f0af"
            }
        },
...
```

マネジメントコンソールから、２つのオブジェクトを消して結果を比べる。

## 参考
- [ファイルストレージ、ブロックストレージ、オブジェクトストレージの比較](https://www.redhat.com/ja/topics/data-storage/file-block-object-storage)
- [Amazon S3における「フォルダ」という幻想をぶち壊し、その実体を明らかにする \| Developers\.IO](https://dev.classmethod.jp/articles/amazon-s3-folders/)
- [ファイルストレージ・ブロックストレージ・オブジェクトストレージの違いと、AWSのストレージサービスとのマッピング \- プログラマでありたい](https://blog.takuros.net/entry/2020/09/06/183748)

