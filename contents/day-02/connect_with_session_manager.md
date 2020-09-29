# セッションマネージャでEC2インスタンスに接続する

## メリット
1. SSH鍵の管理が不要
2. SSHのポート開放が不要
3. インスタンスのパブリックIPアドレス変更の影響がない

## ロールの作成

ロールがまだない場合は作成する。既にインスタンスにアタッチされたロールがある場合は、この手順はスキップする。

## ロールをインスタンスにアタッチ


## ssmエージェント再起動
sshでインスタンスに接続する。

エージェントを再起動すると、権限の変更がエージェントの動作に反映される。

```bash
$ sudo systemctl status amazon-ssm-agent.service
● amazon-ssm-agent.service - amazon-ssm-agent
   Loaded: loaded (/usr/lib/systemd/system/amazon-ssm-agent.service; enabled; vendor preset: enabled)
   Active: active (running) since Mon 2020-09-28 23:26:11 UTC; 2s ago
 Main PID: 3496 (amazon-ssm-agen)
   CGroup: /system.slice/amazon-ssm-agent.service
           └─3496 /usr/bin/amazon-ssm-agent
$ sudo systemctl stop amazon-ssm-agent.service # reloadでは反映されない
$ sudo systemctl start amazon-ssm-agent.service
```

マネジメントコンソールからインスタンスを停止→開始でもよい。インスタンスを作成し直すので、ssmエージェントも再起動される。

## セッションマネージャから接続する

TODO: su - ec2-user

## 説明

[よくある質問 - AWS IAM | AWS](https://aws.amazon.com/jp/iam/faqs/)
> Q: 実行中の EC2 インスタンスで IAM ロールを変更できますか?
> はい。通常、ロールは起動時に EC2 インスタンスに割り当てられますが、既に実行中の EC2 インスタンスに割り当てることもできます。実行中のインスタンスにロールを割り当てる方法については、Amazon EC2 の IAM ロールをご覧ください。実行中のインスタンスに関連付けられている IAM ロールのアクセス許可を変更することもできます。更新されたアクセス許可は、ほぼ即座に反映されます。

TODO: SSTの図
