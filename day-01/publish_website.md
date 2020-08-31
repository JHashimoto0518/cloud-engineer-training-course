# Webサイトを公開する
###### tags: `cetc`,`day01`

## 環境変数を設定する

```bash+=
$ cd
$ pwd
/home/ec2-user
$ vim .bashrc
```

.bashrcに以下を追記する。環境変数`ID`には、自分の名前を入れる。

```bash=
export ID=jhashimoto
export S3_BUCKET_NAME=www.$ID.soft-think.com
```

ログイン中のシェルに環境変数を反映させる。

```bash+=
$ source .bashrc  # . .bashrc でも同じ。
$ echo $S3_BUCKET_NAME
www.jhashimoto.soft-think.com
```

## バケットの作成
```bash=+
$ aws s3api create-bucket --bucket $S3_BUCKET_NAME --acl public-read --create-bucket-configuration LocationConstraint=ap-northeast-1
{
    "Location": "http://www.jhashimoto.soft-think.com.s3.amazonaws.com/"
}
$ aws s3 ls
2020-08-16 16:30:53 www.jhashimoto.soft-think.com
```

## コンテンツ作成

ホームディレクトリ直下にコンテンツディレクトリ (`html`)を作成し、移動する。
```bash=+
$ cd
$ pwd
/home/ec2-user
$ mkdir html
$ cd html
$ pwd
/home/ec2-user/html
```

### welcome.html
```bash=+
$ vim welcome.html
```

```bash=
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
    <title>My Website Home Page</title>
</head>
<body>
  <h1>Welcome to my website</h1>
  <p>Now hosted on Amazon S3!</p>
</body>
</html>
```

### hello.html
```bash=+
$ vim hello.html
```

```bash=
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
    <title>Hello my Website Home Page</title>
</head>
<body>
  <h1>Hello my website</h1>
  <p>Now hosted on Amazon S3!</p>
</body>
</html>
```

## Webサイトの公開

デフォルトコンテンツは、welcome.html。

```bash=+
$ aws s3 website s3://$S3_BUCKET_NAME --index-document welcome.html
```

## コンテンツアップロード
```bash=+
$ aws s3 cp ~/html s3://$S3_BUCKET_NAME --recursive
upload: ./hello.html to s3://www.jhashimoto.soft-think.com/hello.html
upload: ./welcome.html to s3://www.jhashimoto.soft-think.com/welcome.html
```

## welcome.htmlを公開する
welcome.htmlをリクエストすると、'AccessDenied'。

```bash=+
$ curl http://www.$ID.soft-think.com.s3-website-ap-northeast-1.amazonaws.com/welcome.html
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   303  100   303    0     0    949      0 --:--:-- --:--:-- --:--:--   949<html>
<head><title>403 Forbidden</title></head>
<body>
<h1>403 Forbidden</h1>
<ul>
<li>Code: AccessDenied</li>
<li>Message: Access Denied</li>
<li>RequestId: 9113FB676D6CF0FA</li>
<li>HostId: N4k6n3V5Gct/mFzSPDUtQM8y+29iAW9xGAINNrbDdfemVz3bnGmPz5p42dBcvgXQ12atcr9vXv8=</li>
</ul>
<hr/>
</body>
</html>
```

ACLを確認する。

```bash=+
$ aws s3api get-object-acl --bucket $S3_BUCKET_NAME --key welcome.html
{
    "Owner": {
        "DisplayName": "junichi_hashimoto_aws",
        "ID": "20ff705d5e99c4465b612241c5cb440bcfd650c6297ae85bb834c19548e1f0af"
    },
    "Grants": [
        {
            "Grantee": {
                "DisplayName": "junichi_hashimoto_aws",
                "ID": "20ff705d5e99c4465b612241c5cb440bcfd650c6297ae85bb834c19548e1f0af",
                "Type": "CanonicalUser"
            },
            "Permission": "FULL_CONTROL"
        }
    ]
}
```

所有者にフルコントール権限があるが、`All Users グループ`の権限がない。

[アクセスコントロールリスト \(ACL\) の概要 \- Amazon Simple Storage Service](https://docs.aws.amazon.com/ja_jp/AmazonS3/latest/dev/acl-overview.html)
> All Users グループ – http://acs.amazonaws.com/groups/global/AllUsers で表されます。
> 
> このグループへのアクセス許可により、世界中の誰でもリソースにアクセスすることが許可されます。 


All Usersに対して読み取り権限の付与を実行する。

```bash=+
$ aws s3api put-object-acl --bucket $S3_BUCKET_NAME --key welcome.html --acl public-read             ```                
```

権限の付与で`Access Denied`エラーが発生する場合は、バケットのパブリックアクセスブロックを解除する必要がある(補足資料参照）。

```bash=+
An error occurred (AccessDenied) when calling the PutObjectAcl operation: Access Denied
```

権限を確認すると、All Usersへの読み取り権限が付与されている。

```bash=+
$ aws s3api get-object-acl --bucket $S3_BUCKET_NAME --key welcome.html --query 'Grants[]'
[
    {
        "Grantee": {
            "DisplayName": "junichi_hashimoto_aws",
            "ID": "20ff705d5e99c4465b612241c5cb440bcfd650c6297ae85bb834c19548e1f0af",
            "Type": "CanonicalUser"
        },
        "Permission": "FULL_CONTROL"
    },
    {
        "Grantee": {
            "Type": "Group",
            "URI": "http://acs.amazonaws.com/groups/global/AllUsers"
        },
        "Permission": "READ"
    }
]
```

### Tips
`--query`で出力する要素を指定できる。AWS CLIの全コマンド共通のパラメータ。


再び、welcome.htmlをリクエストすると、レスポンスが返ってきた。

```bash=+
$ curl http://www.$ID.soft-think.com.s3-website-ap-northeast-1.amazonaws.com/welcome.html
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   190  100   190    0     0    470      0 --:--:-- --:--:-- --:--:--   471<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
    <title>My Website Home Page</title>
</head>
<body>
  <h1>Welcome to my website</h1>
  <p>Now hosted on Amazon S3!</p>
</body>
</html>
```

デフォルトコンテンツも確認してみる。

```bash=+
$ curl http://www.$ID.soft-think.com.s3-website-ap-northeast-1.amazonaws.com/
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   190  100   190    0     0    503      0 --:--:-- --:--:-- --:--:--   503<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
    <title>My Website Home Page</title>
</head>
<body>
  <h1>Welcome to my website</h1>
  <p>Now hosted on Amazon S3!</p>
</body>
</html>
```

## 全てのコンテンツを公開する

残りのコンテンツも公開する。

```bash=+
$ curl http://www.$ID.soft-think.com.s3-website-ap-northeast-1.amazonaws.com/hello.html
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   303  100   303    0     0    986      0 --:--:-- --:--:-- --:--:--   990<html>
<head><title>403 Forbidden</title></head>
<body>
<h1>403 Forbidden</h1>
<ul>
<li>Code: AccessDenied</li>
<li>Message: Access Denied</li>
<li>RequestId: 8EE139148B98B96C</li>
<li>HostId: 5gv8TUKnrEYhRN++Dhwm8MwMY/CSpVfhr191hOn6xr9Bj02x7TQRaplsKM3aGZ8I7FRPhuIwqn4=</li>
</ul>
<hr/>
</body>
</html>
```

今回はコンテンツファイルが２つしかないので、それぞれのファイルに対してコマンドを実行してもよいが、そのやり方ではスケールしない。

１回のコマンド実行で、コンテンツの全オブジェクトに対して読み取り権限を付与したい。

まず、`s3 ls`でオブジェクト一覧を取得してみる。

```bash=+
$ aws s3 ls s3://$S3_BUCKET_NAME
2020-08-16 17:57:50        191 hello.html
2020-08-16 17:57:50        190 welcome.html
```

さらに`awk`でオブジェクト名だけを取り出してみる。
```bash=+
$ aws s3 ls s3://$S3_BUCKET_NAME | awk '{print $4'}
hello.html
welcome.html
```

`xargs -I`で全オブジェクトをパラメータに指定してコマンドを実行すればよい。
```bash=+
[root@server ~]# aws s3 ls s3://$S3_BUCKET_NAME | awk '{print $4'} | xargs -I{} aws s3api put-object-acl --acl public-read --bucket $S3_BUCKET_NAME --key "{}"
```

hello.htmlの権限を確認してみる。

```bash=+
$ aws s3api get-object-acl --bucket $S3_BUCKET_NAME --key hello.html --query 'Grants[]'
[
    {
        "Grantee": {
            "DisplayName": "junichi_hashimoto_aws",
            "ID": "20ff705d5e99c4465b612241c5cb440bcfd650c6297ae85bb834c19548e1f0af",
            "Type": "CanonicalUser"
        },
        "Permission": "FULL_CONTROL"
    },
    {
        "Grantee": {
            "Type": "Group",
            "URI": "http://acs.amazonaws.com/groups/global/AllUsers"
        },
        "Permission": "READ"
    }
]
```

hello.htmlも公開できた。

```bash=+
$ curl http://www.$ID.soft-think.com.s3-website-ap-northeast-1.amazonaws.com/hello.html
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   191  100   191    0     0    555      0 --:--:-- --:--:-- --:--:--   555<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
    <title>Hello my Website Home Page</title>
</head>
<body>
  <h1>Hello my website</h1>
  <p>Now hosted on Amazon S3!</p>
</body>
</html>
```

## ブラウザからテスト
ブラウザからアクセスして、コンテンツが表示されればOK。URLの`ID`は自分のものに置き換えること。

- `http://www.[ID].soft-think.com.s3-website-ap-northeast-1.amazonaws.com/`
- `http://www.[ID].soft-think.com.s3-website-ap-northeast-1.amazonaws.com/welcome.html`
- `http://www.[ID].soft-think.com.s3-website-ap-northeast-1.amazonaws.com/hello.html`

## 補足資料
### パブリックアクセスブロックの解除

バケットのパブリックアクセスブロックを確認する。

```bash=+
$ aws s3api get-public-access-block --bucket $S3_BUCKET_NAME
{
    "PublicAccessBlockConfiguration": {
        "BlockPublicAcls": true,
        "IgnorePublicAcls": true,
        "BlockPublicPolicy": true,
        "RestrictPublicBuckets": true
    }
}
```

パブリックアクセスブロックを解除する。

```bash=+
$ aws s3api put-public-access-block --bucket $S3_BUCKET_NAME --public-access-block-configuration "BlockPublicAcls = false"
$ aws s3api get-public-access-block --bucket $S3_BUCKET_NAME
{
    "PublicAccessBlockConfiguration": {
        "BlockPublicAcls": false,
        "IgnorePublicAcls": false,
        "BlockPublicPolicy": false,
        "RestrictPublicBuckets": false
    }
}
```

再度、All Usersに対して読み取り権限の付与を実行する。

```bash=+
$ aws s3api put-object-acl --bucket $S3_BUCKET_NAME --key welcome.html --acl public-read
```

