# 動的コンテンツの公開

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
echo "welcome to my dynamic web site"
```
## permission変更

```bash
[root@ip-172-31-34-137 cgi-bin]# chmod 755 welcome.cgi
[root@ip-172-31-34-137 cgi-bin]# ls -l welcome*
-rwxr-xr-x. 1 root root 279 Jun 22 23:04 welcome.cgi
```
## テスト
ローカルPCでブラウザを起動し、以下のURLにアクセスする
- `http://[パブリックDNS]/cgi-bin/welcome.cgi`
