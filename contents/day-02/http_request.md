# HTTP

## HTTPとは

## HTTPリクエスト
HTTPリクエストは、リクエストライン、ヘッダ、ボディから構成される。

TODO: 例

- リクエストライン
	- サーバーに送信するコマンドのこと。どのように、どのリソースを、どのプロトコルで
- ヘッダ
	- ブラウザから送信する追加情報。
	- TODO: 種類（P.1329）
- - ボディ
	- サーバーに送信するデータ。HTMLフォームの要素やファイルデータ。
	- ヘッダとボディは改行で区切られる。

## HTTPレスポンス
HTTPリクエストに対する応答。HTTPレスポンスは、ステータスライン、ヘッダ、ボディから構成される。

TODO: 例

- ステータスライン
	- リクエストの成否を表す。
	- TODO:ステータスコード
- ヘッダ
	- サーバーから返される追加情報。
	- TODO: 種類（P.1348）
	- コンテンツの拡張子とContentsヘッダーの関連付け（Apache）
- ボディ
	- 要求に対するコンテンツデータ。ヘッダとボディは改行で区切られる。 


## TelnetでHTTPリクエストを送信してみる

### インストール
```bash
ec2-user@ip-192-168-11-123 cgi-bin]$ sudo su -
Last login: Tue Sep 29 02:30:46 UTC 2020 on pts/0
[root@ip-192-168-11-123 ~]# yum install telnet -y
Loaded plugins: extras_suggestions, langpacks, priorities, update-motd
amzn2-core                                                                                                                                                             | 3.7 kB  00:00:00
Resolving Dependencies
--> Running transaction check
---> Package telnet.x86_64 1:0.17-65.amzn2 will be installed
--> Finished Dependency Resolution

Dependencies Resolved

==============================================================================================================================================================================================
 Package                                   Arch                                      Version                                              Repository                                     Size
==============================================================================================================================================================================================
Installing:
 telnet                                    x86_64                                    1:0.17-65.amzn2                                      amzn2-core                                     64 k

Transaction Summary
==============================================================================================================================================================================================
Install  1 Package

Total download size: 64 k
Installed size: 109 k
Downloading packages:
telnet-0.17-65.amzn2.x86_64.rpm                                                                                                                                        |  64 kB  00:00:00
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
  Installing : 1:telnet-0.17-65.amzn2.x86_64                                                                                                                                              1/1
  Verifying  : 1:telnet-0.17-65.amzn2.x86_64                                                                                                                                              1/1

Installed:
  telnet.x86_64 1:0.17-65.amzn2

Complete!
[root@ip-192-168-11-123 ~]#
```

### HTTPメソッド
コンテンツに対して何をするか？

`<form method="">`

### Apacheログ

### GET
コンテンツを取得するときに一般に使われる。データはURLに含める。

TODO:yahooのサイトで確認。

```bash
[root@ip-192-168-11-123 cgi-bin]# telnet localhost 80
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
GET /index.html HTTP/1.0

HTTP/1.1 200 OK
Date: Tue, 29 Sep 2020 06:44:52 GMT
Server: Apache
Upgrade: h2,h2c
Connection: Upgrade, close
Last-Modified: Sat, 19 Sep 2020 07:50:29 GMT
ETag: "7d-5afa5defe9c60"
Accept-Ranges: bytes
Content-Length: 125
Content-Type: text/html; charset=UTF-8

<html>
    <head>
        <title>test page</title>
    </head>
    <body>
        Hello web site on EC2!
    </body>
</html>
Connection closed by foreign host.
```

HTTP1.1でリクエストしてみる。

```bash
root@ip-192-168-11-123 cgi-bin]# telnet localhost 80
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
GET /index.html HTTP/1.1

HTTP/1.1 400 Bad Request
Date: Tue, 29 Sep 2020 06:51:49 GMT
Server: Apache
Content-Length: 226
Connection: close
Content-Type: text/html; charset=iso-8859-1

<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<html><head>
<title>400 Bad Request</title>
</head><body>
<h1>Bad Request</h1>
<p>Your browser sent a request that this server could not understand.<br />
</p>
</body></html>
Connection closed by foreign host.
```

リクエストエラーになるのは、1.1ではヘッダの`Host`属性が必須だから。

`Host`を指定して再びリクエストする。

```bash
[root@ip-192-168-11-123 cgi-bin]# telnet localhost 80
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
GET /index.html HTTP/1.1
Host: localhost

HTTP/1.1 200 OK
Date: Tue, 29 Sep 2020 06:50:05 GMT
Server: Apache
Upgrade: h2,h2c
Connection: Upgrade
Last-Modified: Sat, 19 Sep 2020 07:50:29 GMT
ETag: "7d-5afa5defe9c60"
Accept-Ranges: bytes
Content-Length: 125
Content-Type: text/html; charset=UTF-8

<html>
    <head>
        <title>test page</title>
    </head>
    <body>
        Hello web site on EC2!
    </body>
</html>
Connection closed by foreign host.
```

リクエストされたデータをサーバーで取得する。
- 標準仕様？

```bash
$ sudo su -
# cd /var/www/cgi-bin/
# vim read_data.cgi
```

**read_data.cgi**

```bash
#!/bin/bash

echo "Content-Type: text/html"
echo ""

echo "<html><body>"
echo "<p>request_method: ${REQUEST_METHOD}</p>"

if [ ${REQUEST_METHOD} = "GET" ]
then
    declare request_data=${QUERY_STRING}
else if [ ${REQUEST_METHOD} = "POST" ]
    then
        read -n ${CONTENT_LENGTH} request_data
    else
       echo "<p>invalid method: ${REQUEST_METHOD}</p>"
       exit 1
    fi
fi

echo "<p>request_data: ${request_data}</p>"

IFS="&"
set -- ${request_data}

array=($@)

for i in "${array[@]}";
    do IFS="=";
    set -- $i;

    echo "<p>${1} ${2}</p>"
done

echo "</body></html>"
```

```bash
# chmod 755 read_data.cgi
```


```bash
[root@ip-192-168-11-123 cgi-bin]# telnet localhost 80
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
POST /cgi-bin/read_data.cgi HTTP/1.0
Content-Type: application/x-www-form-urlencoded
Content-Length: 21

param1=foo&param2=bar
HTTP/1.1 200 OK
Date: Tue, 29 Sep 2020 06:41:16 GMT
Server: Apache
Upgrade: h2,h2c
Connection: Upgrade, close
Content-Type: text/html; charset=UTF-8

<html><body>
<p>request_method: POST</p>
<p>request_data: param1=foo&param2=bar</p>
<p>param1 foo</p>
<p>param2 bar</p>
</body></html>
Connection closed by foreign host.
```

### POST
入力フォームのデータ送信、ファイル送信。データはボディに含める。

ポストデータは 標準入力から取得できる。
- 標準仕様？

```bash
root@ip-192-168-11-123 cgi-bin]# telnet localhost 80
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
POST /cgi-bin/read_data.cgi HTTP/1.0
Content-Type: application/x-www-form-urlencoded
Content-Length: 21

param1=foo&param2=bar
HTTP/1.1 200 OK
Date: Tue, 29 Sep 2020 05:57:53 GMT
Server: Apache
Upgrade: h2,h2c
Connection: Upgrade, close
Content-Type: text/html; charset=UTF-8

<p>param1=foo&param2=bar</p>
Connection closed by foreign host.
```

[【HTTP通信】telnetをつかってPOSTメソットをリクエストしてみた。｜MsA｜note](https://note.com/ms_a/n/nb0b79a7c386a)
> Q. なぜPOSTにはパラメーターの長さを入れる必要があるのか？ A. GETと違って改行が無いので、どこまでが一つの命令かサーバーが判断するのが難しい。そのためパラメーターの長さ（POSTしたい内容は何文字か）を入力する必要がある。

## 注意

### HTTPの通信をキャプチャする


#### WireShark

#### ブラウザの開発者ツール
- リダイレクト
- httpからhttpsへのリダイレクト（P.1329）
	- 301 Moved Permanently
	- リダイレクト先は、Locationヘッダーで示される

### まとめ
HTTPプロトコルは単純なテキストのやりとり
Webの開発をするなら、ツールを使ってHTTPの通信を見れるように

**.json**

```bash

```


## 補足資料

## 参考
- Network on AWS

テンプレート
---

###
```bash

```

## unused
```bash
C:\Users\xxx>telnet 13.231.109.141 80
CTRL+]
Microsoft Telnet> set localecho
ローカル エコー: オン
Enter→
GET /index.html HTTP/1.0
Enter→
Enter→

HTTP/1.1 200 OK
Date: Mon, 28 Sep 2020 05:03:00 GMT
Server: Apache
Upgrade: h2,h2c
Connection: Upgrade, close
Last-Modified: Sat, 19 Sep 2020 07:50:29 GMT
ETag: "7d-5afa5defe9c60"
Accept-Ranges: bytes
Content-Length: 125
Content-Type: text/html; charset=UTF-8

<html>
          <head>
                        <title>test page</title>
                                                    </head>
                                                               <body>
                                                                             Hello web site on EC2!
                                                                                                       </body>
                                                                                                              </html>

ホストとの接続が切断されました。

C:\Users\xxx>
```

