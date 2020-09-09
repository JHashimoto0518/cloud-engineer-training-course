# 認証情報の設定（IAMユーザー）

## 前提
IAMユーザーのIDが環境変数に設定されている。

```bash+=
$ echo $ID
jhashimoto
```

マネジメントコンソールでIAMユーザーを作成し、ダウンロードした認証情報の.csvがホームディレクトリに配置されている。
```bash=+
$ cd
$ pwd
/c/Users/Junichi
$ ls -l | grep credentials
-rw-r--r-- 1 Junichi 197610      197  8月 16 14:45 new_user_credentials.csv
```

## 認証情報の設定
認証情報をcsvからインポートする。

```bash=+
$ aws configure import --csv file://new_user_credentials.csv
Successfully imported 1 profile(s)
```

:::info
:memo: AWS CLI v1はインポートをサポートしていないので、`aws configure --profile ...`で設定する。

:::

認証情報がインポートされたことを確認する。IAMユーザーのユーザーIDが`profile`に設定されていることがわかる。

```bash=+
$ aws configure list --profile $ID
      Name                    Value             Type    Location
      ----                    -----             ----    --------
   profile               jhashimoto           manual    --profile
access_key     ****************HWUZ shared-credentials-file
secret_key     ****************CbaT shared-credentials-file
    region                <not set>             None    None
```

インポートされた認証情報は、`.aws/credentials`に格納されている。

`cat`でファイルの内容を出力できる。

```bash=+
$ cat .aws/credentials
[jhashimoto]
aws_access_key_id = AKI...
aws_secret_access_key = y9N...
```

`nl`は、行番号付きで出力してくれる。

```bash=+
$ nl .aws/credentials
     1  [jhashimoto]
     2  aws_access_key_id = AKI...
     3  aws_secret_access_key = y9N...
```

コマンドが実行できるかテストする。

パラメータなしで実行すると認証エラーになる。

```bash=+
$ aws s3 ls
Unable to locate credentials. You can configure credentials by running "aws configure".
```

認証を通すには、パラメータで`profile`を指定する必要がある。
```bash=+
$ aws s3 ls --profile jhashimoto
$
```

### デフォルトプロファイルを設定する
コマンド実行のたびにprofileを指定したくない場合は、デフォルトプロファイルを設定できる。

環境変数`AWS_DEFAULT_PROFILE`にprofileを設定すればよい。

```bash=+
$ export AWS_DEFAULT_PROFILE=$ID
$ echo $AWS_DEFAULT_PROFILE
jhashimoto
$ aws s3 ls
$
```

profileパラメータ指定なしで、コマンドが実行できるようになった。

### ログイン時にデフォルトプロファイルを設定する
環境変数はログアウトすると初期化される。 ログイン時に環境変数を設定するには`~/.bashrc`に`export AWS_DEFAULT_PROFILE=...`を記述する。