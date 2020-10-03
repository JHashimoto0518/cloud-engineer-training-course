# EC2インスタンスを自動停止する

サーバーの運用に停止時間を設ける場合は、Cloudwatch Eventsを使うとEC2インスタンスを指定した日時に自動停止させることができる。

## ゴール

毎日18:00にインスタンスを自動停止するように設定する。

## 使用するAWSのサービス

Amazon Cloudwatchは監視のサービス。今回はCloudWatch Eventsというスケジューラの機能を使う。Linuxのcronのようなもの。

## cronと比べたときのメリット

処理を実行するためのサーバーが不要なので、可用性が高く、管理コストが低い。

## マネジメントコンソールにログインし、Cloudwatchを表示

### ルールの作成

#### ステップ1

![](https://i.imgur.com/AxJc0mg.png)
- インスタンスID
	- EC2のインスタンスIDを設定する
- スケジュールのCron式
	- 時差が9時間あるので、日本時間の18:00は、GMTでは09:00になる。

#### ステップ2
![](https://i.imgur.com/hhpLEoJ.png)

## 参考

停止日をカレンダー指定したい場合は、Systems Managerで対応できる。

[Systems Manager で実現する祝日対応の計画的な EC2 停止起動処理をやってみる！ | Developers.IO](https://dev.classmethod.jp/articles/schedule-stopstart-ec2-by-ssm/)

より柔軟にスケジュール管理できる反面、設定は複雑なので、Cloudwatch Eventsと使い分ける。