#!/bin/bash

JQ="jq --raw output --exit-status"

### Deploy process
# 1. Build
# 2. Test
# 3. Deploy

configure_aws_cli () {
  aws --version
  aws configure set default.region us-east-1
  aws configure set default.output json
}

# 1. First we create a new revision of the task definition.
# 2. Update the running service to use the new task definition revision.
# 3. Wait. Tasks will start & stop to update everything to the newest revision.
deploy_cluster () {
  family="gaia-cluster"

  make_task_def
  register_definition

  if [[ $(aws ecs update-service --cluster gaia-cluster --service gaia-service --task-definition $revision | \
      $JQ '.service.taskDefinition') != $revision ]]; then
    echo "Error updating service"
    return 1
  fi
}


# ECS will generate this when you're setting it up through AWS
make_task_def () {
  task_template='[
    {
      "name": "gaia",
      "image": "%s.dkr.ecr.us-east-1.amazonaws.com/gaia:%s",
      "essential": true,
      "memory": 200,
      "cpu": 10,
      "portMappings": [
        {
          "containerPort": 8080,
          "hostPort": 80
        }
      ]
    }
  ]'

  task_def=$(printf "$task_template" $AWS_ACCOUNT_ID $CIRCLE_SHA1)
}

# AWS ECR is a replacement for Docker Hub.
# 1. Create an ECR Repo
# 2. Use the URL prefixed with account id.
# 3. Make sure ECS container agent(s) have access to your ECR repo.
push_registry_image () {
  eval $(aws ecr get-login --region us-east-1)
  docker push $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/gaia:$CIRCLE_SHA1
}

# Each time you tag a new release it will create a new task definition
# ex: docker build -t joshbedo/gaia:3.1.0 -t joshbedo/gaia:latest
register_definition () {
  if revision=$(aws ecs register-task-definition --container-definitions "$task_def" --family $family | $JQ '.taskDefinition.taskDefinitionArn'); then
      echo "Revision: $revision"
  else
      echo "Failed to register task definition"
      return 1
  fi
}

configure_aws_cli
push_registry_image
deploy_cluster
