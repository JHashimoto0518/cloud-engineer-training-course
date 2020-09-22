# 動的コンテンツの公開

前項で静的コンテンツを公開することができた。

ここまではS3のWebサイトホスティングでもできるので、S3ではできない動的コンテンツの公開をする。

動的コンテンツは、追加インストールが不要なCGIスクリプトで実装する。

## Webサーバーにログイン

ローカルPCから`cetc-web-server`にログインする。以降の作業は`cetc-web-server`で行う。

## コンテンツの作成

```bash
$ sudo su -
Last login: Fri Aug 28 01:06:00 UTC 2020 on pts/0
# cd /var/www/cgi-bin
# vim welcome.cgi
```
**welcome.cgi**

```bash
#!/bin/bash

echo "Content-Type: text/html"
echo ""
echo "welcome to my dynamic web site on `date`"
```
## permission変更

```bash
# chmod 755 welcome.cgi
# ls -l welcome*
-rwxr-xr-x. 1 root root 279 Jun 22 23:04 welcome.cgi
```
## テスト

### on ローカルPC

ローカルPCでブラウザを起動し、以下のURLにアクセスする
- `http://[パブリックDNS]/cgi-bin/welcome.cgi`
