## WORK IN PROGRESS

## Infrastructure as code with Terraform

## Running Spring app

### Building the image
`docker build -t spring-demo .`

### Running the container 
`docker run -it -p 8080:8080 --name demo spring-demo`

### Testing the API
POST http://localhost:8080/api/v1/ping

```
Pong
```

### Stop and remove container
`docker stop demo && docker rm demo`

### Remove image
`docker rmi spring-demo`
