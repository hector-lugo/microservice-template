// Jenkinsfile
String CREDENTIALS_ID = 'awsCredentials'
String VERSION = 'latest'
String PROJECT = 'xpresso-microservice'
String IMAGE = env.ECR_URI + '/' + PROJECT + ':' + VERSION
String ECR_URL = 'http://' + env.ECR_URI + '/' + PROJECT
String ECR_CRED = 'ecr:us-east-1:' + CREDENTIALS_ID
Boolean REQUEST_APPROVAL = env.REQUEST_APPROVAL == '0' ? false : true

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
      IMAGE = env.ECR_URI + '/' + PROJECT + ':' + VERSION

      // Generate application properties
      withEnv(["AWS_REGION=us-east-1"]) {
        sh '/opt/confd/bin/confd -confdir ./confd -onetime -backend ssm'
      }
    }
  }

  // Build docker images
  stage('Docker') {
    node {
      def appImage = docker.build(IMAGE, "-f ./containers/spring/Dockerfile .")

      docker.withRegistry(ECR_URL, ECR_CRED) {
        docker.image(IMAGE).push()
      }
    }
  }

  // Run terraform init
  stage('Terraform') {
    node {
      dir('iac') {
        withAWS(credentials: 'awsCredentials', region: 'us-east-1') {
          ansiColor('xterm') {
            sh 'terraform init'
            sh 'terraform plan -var ecs_image=' + IMAGE

            if (env.BRANCH_NAME == 'master') {
              if (REQUEST_APPROVAL) {
                input "Deploy?"
              }

              milestone()
              sh 'terraform apply -auto-approve -var ecs_image=' + IMAGE
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