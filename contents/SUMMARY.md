# Summary

- [はじめに](README.md)

### 環境構築

- [EC2インスタンス作成](./day-01/create_ec2_instance.md)
- [AWS CLI v2インストール](./day-01/install_awscliv2.md)
- 補足資料
  - [手動でリージョン設定するには](./day-01/how_to_set_region_manually.md)
  - IAMロールを使用しない場合は
    - [認証情報の設定（IAMユーザー）](./day-01/set_authentication_with_iamuser.md)

### day-01

- [Intoduction](./day-01/README.md)
- Hosting static web site on Amazon S3
  - [Amazon S3とは](./day-01/s3_introduction.md)
  - [Webサイトを公開する](./day-01/publish_website.md)
- S3の特徴
  - [オブジェクトストレージとは](./day-01/what_is_object_storage.md)
- S3の機能
  - [S3バージョニング](./day-01/s3_versioning.md)
  - [オブジェクトのライフサイクル管理](./day-01/management_of_lifecycle.md)
  - [バケットへの他ユーザーのアクセスを拒否する](./day-01/deny_access_to_bucket.md)
- Appendix
  - [参考資料](./day-01/s3_reference.md)

### day-02

- [Introduction](./day-02/README.md)
- Hosting dynamic web site on Amazon EC2
  - [VPCの構築](./day-02/build_vpc.md)
  - [EC2インスタンスの作成](./day-02/create_ec2.md)
  - [HTTPサーバーの構築](./day-02/build_http_server.md)
  - [動的コンテンツの公開](./day-02/configuration_of_cgi.md)
- [HTTP詳説](./day-02/http_request.md)
- サーバーの運用
    - VPC
		- [VPCログの可視化](./day-02/vpc_flow_log.md)
    - EC2
      - [セッションマネージャによる接続](./day-02/connect_with_session_manager.md)
      - [インスタンス自動停止](./day-02/auto_stop_ec2_instance.md)
      - [固定IPの割り当て](./day-02/assign_elastic_ip.md)
      - [インスタンスのバックアップ](./day-02/backup_ec2_instance.md)

### day-03

- [Introduction](./day-03/basis_of_security.md)
- Authentication and Authorization with IAM
  - [IAMとは](./day-03/what_is_iam.md)
- Hands-On
  - [仮想MFAデバイスによる多要素認証](./day-03/mfa_with_virtual_device.md)
  - [ビジュアルエディタによるポリシーの作成](./day-03/how_to_use_visual_editor.md)

### day-04
- [Introduction](./day-04/README.md)
- Hosting web site at production with Route 53, CloudFront, and Certificate Manager
  - [Certificate Managerとは](./day-04/what_is_certificate_manager.md)
  - [CloudFrontとは](./day-04/what_is_cloudfront.md)
  - [Route 53とは](./day-04/what_is_route53.md)
- Hands-On
  - [AWS Hands-on for Beginners - Static Website Hosting | AWS](https://pages.awscloud.com/JAPAN-event-OE-Hands-on-for-Beginners-StaticWebsiteHosting-2020-reg-event-LP.html)
