# Amazon Route 53とは
ドメインネームシステム (DNS) のマネージドサービス。

# DNSの仕組み

- [DNSサーバとは](https://manual.iij.jp/dns/help/1480649.html)

- ゾーン定義ファイル

# ハンズオン


## 名前解決を試す

CloudShellログイン
- AWSCloudShellFullAccess ポリシーを有効にする

digインストール
```bash
sudo -s
yum install -y bind-utils
```

正引き

```bash
dig www.yahoo.co.jp         		
dig www.yahoo.co.jp ns　		
dig www.yahoo.co.jp mx　		
dig @8.8.8.8 www.yahoo.co.jp
```
逆引き
```bash
dig -x 10.0.0.2
```

## DNSパケットのキャプチャ

- wiresharkインストール
- [OSI参照モデル - ネットワーク入門サイト](https://beginners-network.com/supplement/osi_model.html)
- nslookup

# 応用的な使い方

- マルチAZの冗長化
  - [クラウド時代の可用性向上―サービスレベルに応じた具体策とは？ | Think IT（シンクイット）](https://thinkit.co.jp/story/2014/09/26/5126?page=0%2C1)
- マルチリージョンの冗長化
  - [AWSでリージョン間の自動DR構成を構築してみた #vgadvent2013 - s_tajima:TechBlog](http://s-tajima.hateblo.jp/entry/2013/12/02/100108)
  - ヘルスチェック

# 参考

- [Amazon Route 53（スケーラブルなドメインネームシステム \(DNS\)）\| AWS](https://aws.amazon.com/jp/route53/)
- [Route53 でクエリログが取得できるようになりました \| Developers\.IO](https://dev.classmethod.jp/articles/query-log-from-route53/#toc-3)
- [AWS CloudShell – AWS リソースへのコマンドラインアクセス | Amazon Web Services ブログ](https://aws.amazon.com/jp/blogs/news/aws-cloudshell-command-line-access-to-aws-resources/)

