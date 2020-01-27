### Building the image
`docker build -t spring-demo .`

### Running the container 
`docker run -it -p 8080:8080 --name demo spring-demo`

### Sample insert person API
POST http://localhost:8080/api/v1/person

```
{
  "name": "Tester"
}
```

### Stop and remove container
`docker stop demo && docker rm demo`

### Remove image
`docker rmi spring-demo`
