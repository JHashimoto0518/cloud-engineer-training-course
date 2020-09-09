# IAMポリシーとは

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
