import boto3, json, os, time

ec2Client = boto3.client('ec2')
ecsClient = boto3.client('ecs')
autoscalingClient = boto3.client('autoscaling')
snsClient = boto3.client('sns')
lambdaClient = boto3.client('lambda')


def publishSNSMessage(snsMessage, snsTopicArn):
    response = snsClient.publish(TopicArn=snsTopicArn, Message=json.dumps(snsMessage), Subject='reinvoking')


def setContainerInstanceStatusToDraining(ecsClusterName, containerInstanceArn):
    response = ecsClient.update_container_instances_state(cluster=ecsClusterName,
                                                          containerInstances=[containerInstanceArn], status='DRAINING')


def tasksRunning(ecsClusterName, ec2InstanceId):
    ecsContainerInstances = ecsClient.describe_container_instances(cluster=ecsClusterName, containerInstances=
    ecsClient.list_container_instances(cluster=ecsClusterName)['containerInstanceArns'])['containerInstances']
    for i in ecsContainerInstances:
        if i['ec2InstanceId'] == ec2InstanceId:
            if i['status'] == 'ACTIVE':
                setContainerInstanceStatusToDraining(ecsClusterName, i['containerInstanceArn'])
                return 1
            if (i['runningTasksCount'] > 0) or (i['pendingTasksCount'] > 0):
                return 1
            return 0
    return 2


def lambda_handler(event, context):
    ecsClusterName = os.environ['CLUSTER']
    snsTopicArn = event['Records'][0]['Sns']['TopicArn']
    snsMessage = json.loads(event['Records'][0]['Sns']['Message'])
    lifecycleHookName = snsMessage['LifecycleHookName']
    lifecycleActionToken = snsMessage['LifecycleActionToken']
    asgName = snsMessage['AutoScalingGroupName']
    ec2InstanceId = snsMessage['EC2InstanceId']
    checkTasks = tasksRunning(ecsClusterName, ec2InstanceId)
    if checkTasks == 0:
        try:
            response = autoscalingClient.complete_lifecycle_action(LifecycleHookName=lifecycleHookName,
                                                                   AutoScalingGroupName=asgName,
                                                                   LifecycleActionToken=lifecycleActionToken,
                                                                   LifecycleActionResult='CONTINUE')
        except BaseException as e:
            print(str(e))
    elif checkTasks == 1:
        time.sleep(5)
        publishSNSMessage(snsMessage, snsTopicArn)
