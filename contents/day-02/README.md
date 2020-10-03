# Introduction

## ゴール
- EC2インスタンスにホスティングした動的Webサイトをインターネットに公開する

## ステップ
1. VPCを作成する
2. 作成したVPC内にEC2インスタンスを作成する
3. EC2インスタンスをWebサーバーとして構成する

## VPCとは

- 教科書
    - 5.3 VPCによる仮想ネットワーク構築
- デフォルトVPCとは

## システム構成

### 現在（day-01完了）

![](diagrams/architecture_before.png)

### day-02のゴール

![](diagrams/architecture_after.png)

## SSH接続のセッションについて

しばらく操作がない状態が続くと、SSHのセッションが切断されてしまう。

次の設定で対応できる。

```bash
$ sudo su -
# cd /etc/ssh
# pwd
/etc/ssh
# cp sshd_config sshd_config_org
# ls -l | grep sshd_config
-rw------- 1 root root       3957 Aug 28 00:47 sshd_config
-rw------- 1 root root       3957 Aug 28 00:46 sshd_config_org
```

**sshd_config**

```bash
110c110
< #ClientAliveInterval 0
---
> ClientAliveInterval 60
```

SSHのデーモンを再起動する。
```bash
# systemctl restart sshd.service
```

# FAQ
## SSH接続で`load pubkey "*.pem": invalid format`が出力される

## 再現確認

```bash
$ ssh -V
OpenSSH_8.3p1, OpenSSL 1.1.1g  21 Apr 2020
```

```bash
$ ssh -i ~/keypair/cetc2.pem ec2-user@18.182.15.73
load pubkey "/c/Users/Junichi/keypair/cetc2.pem": invalid format
The authenticity of host '18.182.15.73 (18.182.15.73)' can't be established.
ECDSA key fingerprint is SHA256:EcLmh/5mdBj8GS+HEGjwrfYnizvNEM021nIURFZZu5I.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '18.182.15.73' (ECDSA) to the list of known hosts.
Last login: Thu Oct  1 00:41:09 2020 from 118-87-15-147.odwr.j-cnet.jp

       __|  __|_  )
       _|  (     /   Amazon Linux 2 AMI
      ___|\___|___|

https://aws.amazon.com/amazon-linux-2/
8 package(s) needed for security, out of 25 available
Run "sudo yum update" to apply all updates.
```

## 原因
- [OpenSSH 8.3 client fails with: load pubkey invalid format - Hacker's ramblings](https://blog.hqcodeshop.fi/archives/482-OpenSSH-8.3-client-fails-with-load-pubkey-invalid-format.html)
- [OpenSSH 8.3 client fails with: load pubkey invalid format - Part 2 - Hacker's ramblings](https://blog.hqcodeshop.fi/archives/487-OpenSSH-8.3-client-fails-with-load-pubkey-invalid-format-Part-2.html)

