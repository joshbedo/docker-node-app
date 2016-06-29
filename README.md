# docker-node-app
Simple Docker Node App for ECS

# Prerequisites
This example utilizes AWS information that you wouldn't really want public. You'll need to configure a few CircleCI environment variables before the deploy script will work:

```
AWS_ACCOUNT_ID
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
```

Additionally, an EC2 Container Service cluster and EC2 Container Registry must already be set up on AWS. See the EC2 Container Service Resources and ECS Container Registry Resources to get started. You will also need to update the cluster and task family names in deploy.sh to match your cluster.
