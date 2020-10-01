# EC2インスタンスのバックアップ

バックアップを取得する前にインスタンスを停止する必要があります。

| 属性       | 値                  |
| ---------- | ------------------- |
| イメージ名 | cetc-cli-server-ami |



## インスタンスの停止

```bash
[root@server ~]# aws ec2 stop-instances --instance-ids i-???        
{
	"StoppingInstances": [
		{
			"CurrentState": {
				"Code": 64,
				"Name": "stopping"
			},
			"InstanceId": "i-???",
			"PreviousState": {
				"Code": 16,
				"Name": "running"
			}
		}
	]
}        
[root@server ~]# watch -d aws ec2 describe-instances --instance-ids i-??? --query 'Reservations[].Instances[].[State][].[Name]'
Every 2.0s: aws ec2 describe-instances --instance-ids i-0...  server.mgt.local: Sun Jun 21 17:58:33 2020

[
	[
		"stopping"
	]
]
...
Every 2.0s: aws ec2 describe-instances --instance-ids i-0...  server.mgt.local: Sun Jun 21 17:58:55 2020

[
	[
		"stopped"
	]
]
```
## インスタンスのバックアップ
バックアップを取得する。

TODO: name

```bash
[root@server ~]# aws ec2 create-image --instance-id i-??? --name "{"
{
    "ImageId": "ami-???"
}
```

1. `available`になれば、バックアップは完了している
```bash
[root@server ~]# watch -d aws ec2 describe-images --image-ids ami-??? --query 'Images[].[State]'    
Every 2.0s: aws ec2 describe-images --image-ids ami-08e87...  server.mgt.local: Sun Jun 21 18:09:19 2020

[
    [
        "pending"
    ]
]
...
Every 2.0s: aws ec2 describe-images --image-ids ami-08e87...  server.mgt.local: Sun Jun 21 18:09:54 2020

[
    [
        "available"
    ]
]
```

## インスタンスの開始

```bash
[root@server ~]# aws ec2 start-instances --instance-ids i-???
{
	"StartingInstances": [
		{
			"CurrentState": {
				"Code": 0,
				"Name": "pending"
			},
			"InstanceId": "i-???",
			"PreviousState": {
				"Code": 80,
				"Name": "stopped"
			}
		}
	]
}
[root@server ~]# watch -d aws ec2 describe-instances --instance-ids i-??? --query 'Reservations[].Instances[].[State][].[Name]'

Every 2.0s: aws ec2 describe-instances --instance-ids i-0...  server.mgt.local: Sun Jun 21 17:59:31 2020

[
	[
		"pending"
	]
]
...
Every 2.0s: aws ec2 describe-instances --instance-ids i-0...  server.mgt.local: Sun Jun 21 18:00:05 2020

[
	[
		"running"
	]
]
```

TODO: 
[特定の AWS アカウントと AMI を共有する - Amazon Elastic Compute Cloud/](https://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/sharingamis-explicit.html)