# VPCフローログとは

VPCフローログとは、VPCを送信元/送信先とするIPトラフィックをモニタリングし、ロギングする機能。

[VPC フローログ - Amazon Virtual Private Cloud](https://docs.aws.amazon.com/ja_jp/vpc/latest/userguide/flow-logs.html)

出力先は、Cloudwatch logsとS3から選択できる。

指定できるモニタリングの範囲は、広い順にVPC、サブネット、EC2インスタンスのネットワークインターフェース[^1]。

EC2以外のネットワークインターフェースも指定できる。

> 他の AWS サービスによって作成されたネットワークインターフェイスのフローログを作成できます。たとえば、次のとおりです。
> 
> Elastic Load Balancing
> Amazon RDS
> Amazon ElastiCache
> Amazon Redshift
> Amazon WorkSpaces
> NAT ゲートウェイ
> トランジットゲートウェイ

AWSの仮想ネットワークインターフェースはElastic Network Interface (ENI) と呼ばれる。

[AWSのネットワークインターフェース「ENI」とは｜コラム｜クラウドソリューション｜サービス｜法人のお客さま｜NTT東日本](https://business.ntt-east.co.jp/content/cloudsolution/column-14.html)

[^1]: ネットワーク通信に必要なインターフェース。NIC（ネットワークインターフェースカード）とも呼ばれる。LANケーブルを指す箇所。

## Cloudwatch logsとは
Cloudwatchは、システム監視のサービス。Cloudwatch logsは、Cloudwatchの１機能で、AWS各サービスのログをCloudwatch logsに集約して、分析、視覚化できる。

## VPCフローログを有効にする
今回は、マネジメントコンソールから設定する。

[【新機能】VPC Flow LogsでVPC内のIPトラフィックを監視することができるようになりました! | Developers.IO](https://dev.classmethod.jp/articles/introduce-to-vpc-flow-log/)

1. CloudWatch Logsのグループを作成

2. IAMロール作成

3. VPCフローログ作成

## 後処理

### VPCフローログの削除

Cloudwatch logsは、ログ容量で従量課金されるので、VPCフローログは削除しておく。
無料利用枠は5 GB データ (取り込み、分析のためのスキャン）。

マネジメントコンソールから削除する。

[フローログを使用する - Amazon Virtual Private Cloud](https://docs.aws.amazon.com/ja_jp/vpc/latest/userguide/working-with-flow-logs.html#delete-flow-log)

VPCフローログを削除すると、Cloudwatch logsへのログ出力は停止されるが、蓄積されたログは削除されない。