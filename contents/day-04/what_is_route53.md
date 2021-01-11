# TODO
-  **AWS のネットワークで知っておくべき10のこと**

# Amzon Route 53とは
ドメインネームシステム (DNS) のマネージドサービス。

[Amazon Route 53（スケーラブルなドメインネームシステム \(DNS\)）\| AWS](https://aws.amazon.com/jp/route53/



# DNSとは
- [ ] 新人研修資料
- [ ] **オライリー書籍**
## DNSのしくみ

## ゾーン定義

# 実習
- [ ] サーバー構築手順書から（正引きと逆引き）
    - [ ] 6-1 (1147行目)
        - [ ] wireshark
        - [ ] nslookup (1476行目)

CCNA教科書のDNSページ

## 名前解決を試す

wiresharkインストール

digインストール
```bash
sudo -s
yum install -y bind-utils
```

TODO: wireshark

正引き
```bash
nslookup
dig www.yahoo.co.jp         		
dig www.yahoo.co.jp ns　		
dig www.yahoo.co.jp mx　		
dig @8.8.8.8 www.yahoo.co.jp
```
逆引き
```bash
dig -x 10.0.0.2
```

## DNSクエリログ 
有効化
[Route53 でクエリログが取得できるようになりました \| Developers\.IO](https://dev.classmethod.jp/articles/query-log-from-route53/#toc-3)

cloudwatch logsでバージニアリージョンを選択

[パブリック DNS クエリログ記録 \- Amazon Route 53](https://docs.aws.amazon.com/ja_jp/Route53/latest/DeveloperGuide/query-logs.html)

```
1.0 2021-01-10T05:47:26Z Z0855848ZMRIQ3P4AX3P jhashimoto0518.net NS NOERROR UDP ICN54-C1 18.181.238.75 -
```
# Advanced

- マルチリージョンの冗長化に使用
  - DNSフェイルオーバー
  - ルーティング
- 様々なルーティングタイプ

