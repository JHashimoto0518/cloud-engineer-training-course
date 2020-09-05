# S3バージョニング
###### tags: `cetc`,`day01`

## 前提
環境変数が設定されていること。

```bash=+
echo $S3_BUCKET_NAME
www.jhashimoto.soft-think.com
```

## コンテンツを変更する
welcome.htmlの内容を変更する。

## バージョニングを有効にする
```bash=+
$ aws s3api put-bucket-versioning \
--bucket $S3_BUCKET_NAME \
--versioning-configuration Status=Enabled
```

## コンテンツをアップロードして上書きする
```bash=+
$ aws s3 cp ~/html s3://$S3_BUCKET_NAME \
--recursive
```

コンテンツが更新されたことを確認する。
```bash=+
$ curl http://www.$ID.soft-think.com.s3-website-ap-northeast-1.amazonaws.com/welcome.html
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
    <title>My Website Home Page</title>
</head>
<body>
  <h1>Welcome to my website ver 2.0</h1>
  <p>Now hosted on Amazon S3!</p>
</body>
</html>
```

## 過去バージョンのオブジェクトを管理するには？
### マネジメントコンソール

バージョニングを有効にした後に、マネジメントコンソールで[バージョン]を[表示]に切り替えると、過去バージョンのオブジェクトにアクセスできる。

![](https://i.imgur.com/VTd9Zen.png)

AWS CLIからも過去バージョンを取得できるが、コンテンツが多いときはGUIの方が見やすい。

## コストについて
[Amazon S3 でコストを確認し削減する方法について](https://aws.amazon.com/jp/premiumsupport/knowledge-center/s3-reduce-costs/)
> バケットで バージョニング を有効にしている場合、各オブジェクトには複数のバージョンを含めることができます。各オブジェクトバージョンは、それぞれストレージコストに影響を与えます。

## バージョニングを無効にする
```bash=+
$ aws s3api put-bucket-versioning \
--bucket $S3_BUCKET_NAME \
--versioning-configuration Status=Suspended
```

## バージョニングの用途
- オペレーションミスによるオブジェクトの消失を防ぐ
- リポジトリでバージョン管理されていないファイルの管理
    - 設定ファイルなど
