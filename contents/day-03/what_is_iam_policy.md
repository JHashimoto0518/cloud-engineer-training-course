

# IAMポリシー詳説

## 概要図

![](what_is_iam_policy/iam_policy.png)

３つの観点で分類している。

- 適用する対象
    - アイデンティティベース
        - アイデンティティにアクセス許可を移譲する
    - リソースベース
        - リソースにアクセス許可を移譲する
            - 例: S3のバケット
- オブジェクト/設定値
    - 管理ポリシー
        - 単一のオブジェクトとして管理されるポリシー。
        - 複数のアイデンティティで共用できる。
    - インラインポリシー
        - アイデンティティに対して埋め込まれる設定値。
        - 複数のアイデンティティで共用できない。同一内容のポリシーであっても各アイデンティティ個別に設定する。
        - インラインポリシーの利用は**非推奨**。
- 管理主体
    - AWS管理ポリシー
        - AWSが作成および管理するポリシー。利用者がポリシーの設定を変更できない。
    - カスタマー管理ポリシー
        - AWSアカウントで作成および管理する。利用者がポリシーを柔軟に設定できる。



## 管理ポリシーとカスタマー管理ポリシーの使い分け

セキュリティのマニアックな話



# ref



> ポリシー とは、 AWS の サービス に対する アクセス 権を 設定 し た もの です。 設定 できる ポリシー は 次 の 2 種類 が あり ます。 ● AWS 管理 ポリシー AWS が 作成／ 管理 する 管理 ポリシー です。 ポリシー を 初めて 利用 する 時 は、 この AWS 管理 ポリシー から 開始 する こと を お 勧め し ます。 ● カスタマー 管理 ポリシー AWS アカウント で 作成／ 管理 する 管理 ポリシー です。 AWS 管理 ポリシー よりも 細かく ポリシー を 管理 でき ます。
>

WINGSプロジェクト阿佐志保. Amazon Web Servicesではじめる新米プログラマのためのクラウド超入門 (Kindle Locations 5882-5890).  . Kindle Edition. 



[AWSのポリシーについて簡単にまとめ \- カピバラ好きなエンジニアブログ](https://capybara-engineer.hatenablog.com/entry/2019/11/29/151835)

https://cdn-ak.f.st-hatena.com/images/fotolife/l/live-your-life-dd18/20191129/20191129145326.png
![](https://cdn-ak.f.st-hatena.com/images/fotolife/l/live-your-life-dd18/20191129/20191129145326.png)

[アクセス管理の概要: アクセス許可とポリシー - AWS Identity and Access Management](https://docs.aws.amazon.com/ja_jp/IAM/latest/UserGuide/introduction_access-management.html)
> AWS でのアクセスを管理するには、ポリシーを作成し、IAM アイデンティティ (ユーザー、ユーザーのグループ、ロール) または AWS リソースにアタッチします。ポリシーは AWS のオブジェクトであり、アイデンティティやリソースに関連付けて、これらのアクセス許可を定義します。AWS は、プリンシパルが IAM エンティティ (ユーザーまたはロール) を使用してリクエストを行うと、それらのポリシーを評価します。ポリシーでのアクセス許可により、リクエストが許可されるか拒否されるかが決まります。

[アクセス管理の概要: アクセス許可とポリシー - AWS Identity and Access Management](https://docs.aws.amazon.com/ja_jp/IAM/latest/UserGuide/introduction_access-management.html)
> アイデンティティベースのポリシーは、IAM アイデンティティ (IAM ユーザー、グループ、ロール プリンシパル) にアタッチするアクセス許可ポリシーです。リソースベースのポリシーは、Amazon S3 バケットなどのリソースまたは IAM ロール信頼ポリシーにアタッチするアクセス許可ポリシーです。
>
> アイデンティティベースのポリシーでは、アイデンティティが実行できるアクション、リソース、および条件を制御します。アイデンティティベースのポリシーはさらに次のように分類できます。
>
> 管理ポリシー – AWS アカウント内の複数のユーザー、グループ、およびロールにアタッチできるスタンドアロンのアイデンティティベースのポリシーです。次の 2 種類の管理ポリシーを使用できます。
>
> AWS 管理ポリシー – AWS が作成および管理する管理ポリシー。ポリシーを初めて利用する場合は、AWS 管理ポリシーから開始することをお勧めします。
>
> カスタマー管理ポリシー – AWS アカウントで作成および管理する管理ポリシー。カスタマー管理ポリシーでは、AWS 管理ポリシーに比べて、より正確にポリシーを管理できます。ビジュアルエディタで IAM ポリシーを作成および編集することも、JSON ポリシードキュメントを直接作成することもできます。詳細については、「IAM ポリシーの作成」および「IAM ポリシーの編集」を参照してください。
>
> インラインポリシー – お客様が作成および管理するポリシーであり、単一のユーザー、グループ、またはロールに直接埋め込まれます。通常、インラインポリシーを使用することは推奨されていません。
>
> リソースベースのポリシーでは、指定されたプリンシパルが実行できるリソースと条件を制御します。リソースベースのポリシーはインラインポリシーであり、管理リソースベースのポリシーはありません。

[IAM ポリシーを管理する - AWS Identity and Access Management](https://docs.aws.amazon.com/ja_jp/IAM/latest/UserGuide/access_policies_manage.html)
> IAM アイデンティティ (IAM のユーザー、グループ、またはロール) にアクセス権限を追加するには、ポリシーを作成してアイデンティティにアタッチします。アイデンティティに複数のポリシーをアタッチし、各ポリシーに複数のアクセス許可を含めることができます。

## ポリシーの例
[IAM アイデンティティベースのポリシーの例 - AWS Identity and Access Management](https://docs.aws.amazon.com/ja_jp/IAM/latest/UserGuide/access_policies_examples.html)

## 要素の説明
[IAM JSON ポリシーリファレンス - AWS Identity and Access Management](https://docs.aws.amazon.com/ja_jp/IAM/latest/UserGuide/reference_policies.html)

## 参考

- [プリンシパル - Amazon Simple Storage Service](https://docs.aws.amazon.com/ja_jp/AmazonS3/latest/dev/s3-bucket-user-policy-specifying-principal-intro.html)
- [AWS JSON ポリシーの要素:Principal - AWS Identity and Access Management](https://docs.aws.amazon.com/ja_jp/IAM/latest/UserGuide/reference_policies_elements_principal.html)
 [IAM および AWS STS の条件コンテキストキー - AWS Identity and Access Management](https://docs.aws.amazon.com/ja_jp/IAM/latest/UserGuide/reference_policies_iam-condition-keys.html)