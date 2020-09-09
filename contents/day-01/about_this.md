###### tags: `cetc`,`day01`
# この手順書について
## 実習環境
- AWSマネージメントコンソール
    - FirefoxまたはChromeを推奨。IEは不可。
- ローカルPC
    - SSHが実行できればよい。Windows 10であれば、Git BashかTeraTermを推奨。

## コピー＆ペーストについて
- AWSのコマンドは長いので、手順書からコピー＆ペーストしてもかまいませんが、何をやっているのかを、理解しつつ進めてください。

## 手順の表記について
### 入力するコマンド
```bash=
$ ls -l
```
`$`はプロンプトを表します。`$`以降の`ls -l`が入力するコマンドです。

### 省略記号
`...`は、出力の省略を表します。

```bash=
$ ls -l aws*
-rw-r--r--. 1 root root 33105191  6月 20 12:03 awscliv2.zip
$ unzip awscliv2.zip 
Archive:  awscliv2.zip
   creating: aws/
   creating: aws/dist/
  inflating: aws/README.md           
...
   creating: aws/dist/lib/python3.7/
   creating: aws/dist/lib/python3.7/config-3.7m-x86_64-linux-gnu/
  inflating: aws/dist/lib/python3.7/config-3.7m-x86_64-linux-gnu/Makefile  
```

