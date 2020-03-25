# Spring Boot microservice running on ECS

## Highlights
This repository provides a template for a Spring Boot microservice. By using this template you get:
- A Spring Boot application with a health endpoint
- The code to build and run the application inside a Docker container
- The Terraform code required to deploy the application inside an ECS cluster
- A Jenkinsfile that can be used implement CI/CD for the project

## Pre-requisites
- An AWS account with an IAM user with permissions to use the services involved in the deployment process
- An ECR repository. If you need to use a different registry for your Docker images, just update the Jenkinsfile and inject the correct image into the Terraform deployment
- An S3 bucket to store the state file for the Terraform deployment
    - Please note that you will need to update the `iac/connection.tf` file with the correct location of the S3 bucket
- A Jenkins node running Terraform 0.12+ and with the following plugins installed
    - Docker
    - ECR
    - (Github)

## Infrastructure as code with Terraform
The Terraform code provides a the basic infrastructure to run a highly available and fault tolerant microservice. The code separates the different components in modules as follows:
- *vpc* Provides the infrastructure required for virtual network isolation. By default it will create a VPC with 2 public subnets and the required routes to an Internet Gateway (also created as part of the deployment) and 2 private subnets, each with a NAT Gateway association and with the route tables required to route the traffic accordingly
- *load_balancers* Provides an Application Load Balancer with a Target Group, configured to listen on port 80
- *security_groups* Provides the required Security Groups to control traffic directed to the Application Load Balancer as well as the traffic directed to the instances in associated with the ECS cluster
- *ecs_cluster* Provides an ECS cluster along with an Autoscaling Group configured to scale instances running the application up and down based on the CPU usage. This module also provides the configuration required to launch instances associated with the cluster, including the required IAM roles needed by the instances in order to interact with ECS
- *service* Provides a service that will run the Spring Boot application based on the image created as part of the build in the pipeline

## Running the Spring Boot app locally
In order to run the application locally you will need Docker installed and configured.

NOTE: All commands are run relative to the root of project. 

### Using Docker compose
The simplest way to run the application locally is using docker compose. A compose file is provided as part of this code and can be used by running:
`docker-compose up`

### Using Docker files
There are several reasons to use Docker directly, the main one in my opinion being supporting experimental features like Buildkit

#### Building the image
`docker build -t spring-demo .`

#### Running the container 
`docker run -it -p 80:80 --name demo spring-demo`

### Testing the API
You can test the result by navigating to:
`http://localhost/api/v1/ping`

You should receive a 200 response with the following body:
```
Pong
```

#### For Windows users
If you are using Windows there is a big chance that using localhost will not work out of the box. If this happens please use the ip of the Docker machine instead, ie:
```
$ docker-machine ip
192.168.99.101
```

The navigate to: `http://192.168.99.101/api/v1/ping`

### Stop and remove container
`docker stop demo && docker rm demo`

### Remove image
`docker rmi spring-demo`
