// Jenkinsfile
String CREDENTIALS_ID = 'awsCredentials'
String VERSION = 'latest'
String PROJECT = 'xpresso-microservice'
String IMAGE = 'xpresso-microservice:latest'
String ECR_URL = env.ECR_URL
String ECR_CRED = 'ecr:us-east-1:' + CREDENTIALS_ID

try {
  stage('prepare') {
    node {
      cleanWs()
      checkout scm

      // calculate GIT lastest commit short-hash
       gitCommitHash = sh(returnStdout: true, script: 'git rev-parse HEAD').trim()
       shortCommitHash = gitCommitHash.take(7)

       // calculate a sample version tag
       VERSION = shortCommitHash

       // set the build display name
       IMAGE = "$PROJECT:$VERSION"
    }
  }

  // Build docker images
  stage('Docker') {
    node {
        def appImage = docker.build("${IMAGE}", "-f ./containers/spring/Dockerfile .")

        docker.withRegistry(ECR_URL, ECR_CRED) {
          docker.image(IMAGE).push()
        }
    }
  }

  // Run terraform init
  stage('Terraform') {
    node {
      dir('iac') {
        withCredentials([[
          $class: 'AmazonWebServicesCredentialsBinding',
          credentialsId: CREDENTIALS_ID,
          accessKeyVariable: 'AWS_ACCESS_KEY_ID',
          secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
        ]]) {
          ansiColor('xterm') {
            sh 'terraform init'
            sh 'terraform plan'

            if (env.BRANCH_NAME == 'master') {
              sh 'terraform apply -auto-approve'
              sh 'terraform show'
            }
          }
        }
      }
    }
  }

  currentBuild.result = 'SUCCESS'
}
catch (org.jenkinsci.plugins.workflow.steps.FlowInterruptedException flowError) {
  currentBuild.result = 'ABORTED'
}
catch (err) {
  currentBuild.result = 'FAILURE'
  throw err
}
finally {
  if (currentBuild.result == 'SUCCESS') {
    currentBuild.result = 'SUCCESS'
  }

  node {
    sh "docker rmi $IMAGE | true"
  }
}