# httpサーバー構築

## ゴール
`cetc-web-server`にApacheをインストールして、コンテンツを公開する。

## ステップ
1. Apacheのインストール
2. Apacheの設定
3. Apacheの起動
4. httpdの自動起動を設定
5. コンテンツの作成

## 前提
環境変数が設定されていること。

```bash
echo $S3_BUCKET_NAME
www.jhashimoto.soft-think.com
```

## Apacheのインストール
rootでログイン

```bash
[ec2-user@ip-192-168-10-60 ~]$ sudo su -
Last failed login: Thu Sep 17 00:43:05 UTC 2020 on pts/1
There was 1 failed login attempt since the last successful login.
```

```bash
[ec2-user@ip-192-168-10-60 ~]$ rpm -q httpd
package httpd is not installed
[ec2-user@ip-192-168-10-60 ~]$ yum install httpd -y
Loaded plugins: extras_suggestions, langpacks, priorities, update-motd
amzn2-core
...
Complete!
```

```bash
[ec2-user@ip-192-168-10-60 ~]$ ls -l /etc/httpd
total 0
drwxr-xr-x 2 root root  37 Sep 17 00:35 conf
drwxr-xr-x 2 root root  82 Sep 17 00:35 conf.d
drwxr-xr-x 2 root root 226 Sep 17 00:35 conf.modules.d
lrwxrwxrwx 1 root root  19 Sep 17 00:35 logs -> ../../var/log/httpd
lrwxrwxrwx 1 root root  29 Sep 17 00:35 modules -> ../../usr/lib64/httpd/modules
lrwxrwxrwx 1 root root  10 Sep 17 00:35 run -> /run/httpd
lrwxrwxrwx 1 root root  19 Sep 17 00:35 state -> ../../var/lib/httpd
```

## Apacheの設定
```bash
[root@ip-172-31-34-137 ~]# cd /etc/httpd/conf
[ec2-user@ip-192-168-10-60 conf]$ ls -l
total 28
-rw-r--r-- 1 root root 11910 May  8 17:01 httpd.conf
-rw-r--r-- 1 root root 13064 May  8 17:03 magic
[root@ip-172-31-34-137 conf]# cp httpd.conf httpd.conf_org
[root@ip-192-168-10-60 conf]# ls -l | grep httpd
-rw-r--r-- 1 root root 11910 May  8 17:01 httpd.conf
-rw-r--r-- 1 root root 11910 Sep 17 00:55 httpd.conf_org
[root@ip-172-31-34-137 conf]# vim httpd.conf
```

### Configを変更
```bash
89c89
< ServerAdmin root@localhost
---
> ServerAdmin root@$EC2_PUB_DNS
98c98
< #ServerName www.example.com:80
---
> ServerName $EC2_PUB_DNS:80
319c319
< AddDefaultCharset UTF-8
---
> AddDefaultCharset Off 
356a357,359
> 
> ServerTokens Prod
> ServerSignature Off
```

### 参考
diffコマンドで差分を出力できる

```bash
[root@ip-172-31-34-137 conf]# diff --color httpd.conf_org httpd.conf
```

### Apacheの起動
```bash
[root@ip-172-31-34-137 conf]# apachectl configtest
Syntax OK
[root@ip-172-31-34-137 conf]# systemctl status httpd
● httpd.service - The Apache HTTP Server
   Loaded: loaded (/usr/lib/systemd/system/httpd.service; disabled; vendor preset: disabled)
   Active: inactive (dead)
     Docs: man:httpd.service(8)
[root@ip-172-31-34-137 conf]# systemctl start httpd
[root@ip-172-31-34-137 conf]# systemctl status httpd
● httpd.service - The Apache HTTP Server
   Loaded: loaded (/usr/lib/systemd/system/httpd.service; disabled; vendor preset: disabled)
   Active: active (running) since Mon 2020-06-22 21:42:54 UTC; 8s ago
     Docs: man:httpd.service(8)
 Main PID: 932 (httpd)
   Status: "Started, listening on: port 80"
    Tasks: 213 (limit: 5013)
   Memory: 24.5M
   CGroup: /system.slice/httpd.service
           ├─932 /usr/sbin/httpd -DFOREGROUND
           ├─933 /usr/sbin/httpd -DFOREGROUND
           ├─934 /usr/sbin/httpd -DFOREGROUND
           ├─935 /usr/sbin/httpd -DFOREGROUND
           └─936 /usr/sbin/httpd -DFOREGROUND

Jun 22 21:42:54 ip-172-31-34-137.ap-northeast-1.compute.internal systemd[1]: Starting The Apache HTTP S>
Jun 22 21:42:54 ip-172-31-34-137.ap-northeast-1.compute.internal systemd[1]: Started The Apache HTTP Se>
Jun 22 21:42:54 ip-172-31-34-137.ap-northeast-1.compute.internal httpd[932]: Server configured, listeni>
```

なお、ファイアウォールの設定は不要。
```bash
[root@ip-172-31-34-137 conf]# systemctl status firewalld.service
Unit firewalld.service could not be found.
```

### httpdの自動起動を設定
```bash
[root@ip-172-31-34-137 conf]# systemctl enable httpd
Created symlink /etc/systemd/system/multi-user.target.wants/httpd.service → /usr/lib/systemd/system/httpd.service.
[root@ip-172-31-34-137 conf]# systemctl is-enabled httpd
enabled
```

### コンテンツの作成
```bash
[root@ip-172-31-34-137 conf]# vim /var/www/html/index.html
```

```html
<html>
    <head>
        <title>test page</title>
    </head>
    <body>
        Hello web site on EC2!
    </body>
</html>
```

### 動作確認
localhostでコンテンツを参照できることを確認する。

```bash
[root@ip-192-168-10-60 conf]# curl http://localhost
<html>
    <head>
        <title>test page</title>
    </head>
    <body>
        Hello web site on EC2!
    </body>
</html>
```
なお、IPアドレスで自身を参照するときは、**Private** IPアドレスを使用すること。Public IPアドレスでは、サーバーは見つからない。

Private IPアドレスを確認する。

```bash
[root@ip-192-168-10-60 conf]# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9001 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 06:00:95:e2:e4:02 brd ff:ff:ff:ff:ff:ff
    inet 192.168.10.60/25 brd 192.168.10.127 scope global dynamic eth0
       valid_lft 3147sec preferred_lft 3147sec
    inet6 fe80::400:95ff:fee2:e402/64 scope link
       valid_lft forever preferred_lft forever
```

```bash
[root@ip-172-31-34-137 ~]# curl http://192.168.10.60
<html>
    <head>
        <title>test page</title>
    </head>
    <body>
        Hello web site on EC2!
    </body>
</html>
```

インターネットに公開されたことを確認する。ローカルPCでブラウザを起動し、コンテンツが表示できればOK。

- http://[Public IP]/
