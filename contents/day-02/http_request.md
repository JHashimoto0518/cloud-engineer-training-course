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
[Windows10で「Telnet」コマンドを使えるように設定する方法 | 今村だけがよくわかるブログ](https://www.imamura.biz/blog/27493)

### HTTPメソッド
コンテンツに対して何をするか？

`<form method="">`

### GET
コンテンツを取得するときに一般に使われる。データはURLに含める。

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
- QUERYSTRING
	- TODO: CGI 
	- 標準仕様？
- Enter２回

**/var/www/cgi-bin/get.cgi**

```bash
#!/bin/bash

echo "Content-Type: text/html"
echo ""

#echo ${QUERY_STRING}
#echo `echo "${QUERY_STRING}"|tr '&' ';'`

declare query=${QUERY_STRING}

echo "<p>"
echo "query string: ${query}"
echo "</p>"

IFS="&"
set -- ${query}

array=($@)

for i in "${array[@]}";
    do IFS="=";
    set -- $i;

    echo "<p>"
    echo ${1} ${2};
    echo "</p>"
done
```

[root@ip-192-168-11-123 cgi-bin]# vim get.cgi
[root@ip-192-168-11-123 cgi-bin]# chmod get.cgi 755
chmod: invalid mode: ‘get.cgi’
Try 'chmod --help' for more information.
[root@ip-192-168-11-123 cgi-bin]# chmod 755 get.cgi


### POST
入力フォームのデータ送信、ファイル送信。データはボディに含める。
- 標準入力
	- TODO
		- post with telnet
	    - read_data.cgiテスト 
	- 標準仕様？
- Content Lengthでデータが切られること

### 注意

### HTTPの通信をキャプチャする
- ブラウザの開発者ツール
- WireShark

## リダイレクト
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
