# AWS CLI v2インストール

## CLIバージョン確認
v1がインストールされている。

```bash+=
$ aws --version
aws-cli/1.16.300 Python/2.7.18 Linux/4.14.186-146.268.amzn2.x86_64 botocore/1.13.36
```

## CLI v2インストール
CLI v2をダウンロード。

```bash+=
$ curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 31.8M  100 31.8M    0     0  91.3M      0 --:--:-- --:--:-- --:--:-- 91.1M
$ ls awscli*
awscliv2.zip
```

Zipファイルを展開する。

```bash+=
$ unzip awscliv2.zip
Archive:  awscliv2.zip
   creating: aws/
   creating: aws/dist/
  inflating: aws/THIRD_PARTY_LICENSES
...
    inflating: aws/dist/awscli/customizations/wizard/wizards/iam/new-role.yml
   creating: aws/dist/zlib/cpython-37m-x86_64-linux-gnu/
  inflating: aws/dist/zlib/cpython-37m-x86_64-linux-gnu/soib.cpython-37m-x86_64-linux-gnu.so
$ ls awscli*
awscliv2.zip
$ ls -la
total 32680
drwx------ 4 ec2-user ec2-user      126 Aug 21 06:29 .
drwxr-xr-x 3 root     root           22 Aug 21 04:08 ..
drwxr-xr-x 3 ec2-user ec2-user       78 Aug 20 21:33 aws
-rw-rw-r-- 1 ec2-user ec2-user 33445969 Aug 21 06:28 awscliv2.zip
-rw------- 1 ec2-user ec2-user       49 Aug 21 05:44 .bash_history
-rw-r--r-- 1 ec2-user ec2-user       18 Jan 16  2020 .bash_logout
-rw-r--r-- 1 ec2-user ec2-user      193 Jan 16  2020 .bash_profile
-rw-r--r-- 1 ec2-user ec2-user      231 Jan 16  2020 .bashrc
drwx------ 2 ec2-user ec2-user       29 Aug 21 04:08 .ssh
[ec2-user@ip-172-31-47-39 aws]$ ls -l aws
total 80
drwxr-xr-x 11 ec2-user ec2-user  4096 Aug 20 21:33 dist
-rwxr-xr-x  1 ec2-user ec2-user  4047 Aug 20 21:00 install
-rw-r--r--  1 ec2-user ec2-user  1465 Aug 20 21:00 README.md
-rw-r--r--  1 ec2-user ec2-user 68271 Aug 20 21:00 THIRD_PARTY_LICENSES
```

インストールして、バージョンを確認する。
```bash=+
$ sudo ./aws/install
You can now run: /usr/local/bin/aws --version
$ /usr/local/bin/aws --version
aws-cli/2.0.42 Python/3.7.3 Linux/4.14.186-146.268.amzn2.x86_64 exe/x86_64.amzn.2
```

パスが通っていることを確認する。
```bash=+
$ which aws
/usr/local/bin/aws
$ aws --version
aws-cli/2.0.42 Python/3.7.3 Linux/4.14.186-146.268.amzn2.x86_64 exe/x86_64.amzn.2
```

バージョンがv1のままの場合は、シェルをログアウトして、ログインし直す。

シンボリックリンクの指し先を調べる。
```bash=+
$ ls -l /usr/local/bin/aws  # ls -l `which aws`　これでもよい
lrwxrwxrwx 1 root root 37 Aug 21 23:22 /usr/local/bin/aws -> /usr/local/aws-cli/v2/current/bin/aws
```

## 認証情報の確認
シークレットアクセスキーはIAMロールから、RegionはIMDS[^imds]から取得されていることがわかる。

AWS CLIの実行には、この認証情報が使われる。

```bash=+
$ aws configure list
      Name                    Value             Type    Location
      ----                    -----             ----    --------
   profile                <not set>             None    None
access_key     ****************7I3E         iam-role
secret_key     ****************lINz         iam-role
    region           ap-northeast-1             imds
```

IAMロールを使えば、**IAMユーザーを作成してアクセスキーを払い出すことなく**、アプリケーションを実行できる。

[^imds]: 
    Instance Metadata Service。EC2インスタンスにインストールされたコンポーネント。インスタンスのメタデータにアクセスできる。 

## クリーンアップ
```bash=+
$ rm awscliv2.zip
```

## リージョンとは？
- 教科書
    - 2.3 AWSのデータセンター



