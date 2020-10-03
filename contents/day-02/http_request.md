# HTTP詳説

## HTTPリクエスト

HTTPリクエストは、リクエストライン、ヘッダ、ボディから構成される。

POSTリクエストの例。

```bash
POST /cgi-bin/read_data.cgi HTTP/1.0             ←リクエストライン
Content-Type: application/x-www-form-urlencoded  ←ヘッダここから
Content-Length: 21                               ←ヘッダここまで
　　　　　　　　　　　　　　　　　　　　　　　　　　　　　 ←改行
param1=foo&param2=bar　　　　　　　　　　　　　　　　　←ボディ
```

- リクエストライン
	- サーバーに送信するコマンドのこと。Method, Resource, Protocolから構成される。
- ヘッダ
	- ブラウザから送信する追加情報。
- ボディ
  - サーバーに送信するデータ。HTMLフォームの要素やファイルデータ。
  - ヘッダとボディは改行で区切られる。

## HTTPレスポンス

HTTPリクエストに対する応答。HTTPレスポンスは、ステータスライン、ヘッダ、ボディから構成される。

レスポンスの例。

```bash
HTTP/1.1 200 OK                         ←ステータスライン
Date: Tue, 29 Sep 2020 05:57:53 GMT     ←ヘッダここから
Server: Apache
Upgrade: h2,h2c
Connection: Upgrade, close
Content-Type: text/html; charset=UTF-8  ←ヘッダここまで
                                        ←改行
<html>                                  ←ボディここから
<body>
...
</body>
</html>
```

- ステータスライン
	- リクエストの成否を表す。
- ヘッダ
	- サーバーから返される追加情報。
- ボディ
	- 要求に対するコンテンツデータ。ヘッダとボディは改行で区切られる。 

## TelnetでHTTPリクエストを送信してみる

### インストール

```bash
$ sudo su -
Last login: Tue Sep 29 02:30:46 UTC 2020 on pts/0
# yum install telnet -y
Loaded plugins: extras_suggestions, langpacks, priorities, update-motd
...
Complete!
# exit
```

### GETリクエスト

コンテンツを取得するときに一般に使われる。データはURLに含める。

```bash
# telnet localhost 80
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
# telnet localhost 80
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

リクエストエラーになるのは、HTTP1.1ではヘッダの`Host`属性が必須だから。

`Host`を指定して再びリクエストする。

```bash
# telnet localhost 80
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

今度は成功した。

Host属性が必要な理由は、1.1で名前ベースのバーチャルホストが実装されたため。

[名前ベースのバーチャルホスト - Apache HTTP サーバ バージョン 2.4](https://httpd.apache.org/docs/2.4/ja/vhosts/name-based.html)

> IP ベースのバーチャルホストでは、応答する バーチャルホストへのコネクションを決定するために IP アドレスを使用します。ですから、それぞれのホストに個々に IP アドレスが必要になります。これに対して名前ベースのバーチャルホストでは、 クライアントが HTTP ヘッダの一部としてホスト名を告げる、 ということに依存します。この技術で同一 IP アドレスを異なる多数のホストで共有しています。

### 送信データをサーバーで取得する

#### CGI作成

```bash
$ sudo su -
# cd /var/www/cgi-bin/
# vim read_data.cgi
```

**read_data.cgi**

```bash
#!/bin/bash

echo "Content-Type: text/html"

# ボディの前の改行
echo ""

echo "<html><body>"
echo "<p>request_method: ${REQUEST_METHOD}</p>"

# 送信データの取得
if [ ${REQUEST_METHOD} = "GET" ]
then
    # GETの場合は環境変数
    declare request_data=${QUERY_STRING}
else if [ ${REQUEST_METHOD} = "POST" ]
    then
　　　　# POSTの場合は標準出力
        read -n ${CONTENT_LENGTH} request_data
    else
       echo "<p>invalid method: ${REQUEST_METHOD}</p>"
       exit 1
    fi
fi

echo "<p>request_data: ${request_data}</p>"

# 送信データからパラメータをパース
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

#### GET

```bash
# telnet localhost 80
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
GET /cgi-bin/read_data.cgi?param1=foo&param2=bar HTTP/1.0

HTTP/1.1 200 OK
Date: Sat, 03 Oct 2020 01:53:08 GMT
Server: Apache
Upgrade: h2,h2c
Connection: Upgrade, close
Content-Type: text/html; charset=UTF-8

<html><body>
<p>request_method: GET</p>
<p>request_data: param1=foo&param2=bar</p>
<p>param1 foo</p>
<p>param2 bar</p>
</body></html>
Connection closed by foreign host.
```

#### POST

POSTリクエストは、ヘッダの`Content-Length`属性が必須。GETと違って送信データに改行がないので、データ長がないとサーバー側で読みだせない。

```bash
# telnet localhost 80
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

## Apacheログ

Apacheのログを確認する。

```bash
# cd /etc/httpd/logs/
# ls -l
total 44
-rw-r--r-- 1 root root 21491 Oct  3 01:13 access_log
-rw-r--r-- 1 root root 18660 Oct  2 22:01 error_log
```
アクセスログ。

```bash
root@ip-192-168-10-17 logs]# tail -n 5 access_log
127.0.0.1 - - [03/Oct/2020:01:21:58 +0000] "GET /index.html HTTP/1.0" 200 125 "-" "-"
127.0.0.1 - - [03/Oct/2020:01:22:43 +0000] "GET /index.html HTTP/1.1" 400 226 "-" "-"
127.0.0.1 - - [03/Oct/2020:01:23:16 +0000] "GET /index.html HTTP/1.1" 200 125 "-" "-"
127.0.0.1 - - [03/Oct/2020:01:51:20 +0000] "POST /cgi-bin/read_data.cgi HTTP/1.0" 200 135 "-" "-"
127.0.0.1 - - [03/Oct/2020:01:53:08 +0000] "GET /cgi-bin/read_data.cgi?param1=foo&param2=bar HTTP/1.0" 200 134 "-" "-"
```

エラーログ。

```bash
root@ip-192-168-10-17 logs]# tail -n 5 error_log
[Fri Oct 02 22:01:20.592316 2020] [http2:warn] [pid 3069] AH10034: The mpm module (prefork.c) isnot supported by mod_http2. The mpm determines how things are processed in your server. HTTP/2 has more demands in this regard and the currently selected mpm will just not do. This is an advisory warning. Your server will continue to work, but the HTTP/2 protocol will be inactive.
[Fri Oct 02 22:01:20.592322 2020] [http2:warn] [pid 3069] AH02951: mod_ssl does not seem to be enabled
[Fri Oct 02 22:01:20.596214 2020] [mpm_prefork:notice] [pid 3069] AH00163: Apache/2.4.46 () configured -- resuming normal operations
[Fri Oct 02 22:01:20.596241 2020] [core:notice] [pid 3069] AH00094: Command line: '/usr/sbin/httpd -D FOREGROUND'
[Sat Oct 03 01:51:38.841148 2020] [cgi:error] [pid 3101] [client 127.0.0.1:40616] AH01215: /var/www/cgi-bin/read_data.cgi: line 18: $'\\343\\200\\200\\343\\200\\200\\343\\200\\200\\343\\200\\200#': command not found: /var/www/cgi-bin/read_data.cgi
```