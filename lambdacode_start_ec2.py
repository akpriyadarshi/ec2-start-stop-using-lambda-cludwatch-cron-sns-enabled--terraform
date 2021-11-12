import boto3
client = boto3.client('sns')
region = 'ap-south-1'
instances = ['i-03d4f1ec3aa015cdd']
ec2 = boto3.client('ec2', region_name=region)

def lambda_handler(event, context):
    ec2.start_instances(InstanceIds=instances)
    print('started your instances: ' + str(instances))
    client.publish(
        TopicArn = 'arn:aws:sns:ap-south-1:269763233488:Default_CloudWatch_Alarms_Topic',
        Message = 'hi!!! Ec2-instance has been started using lambda'
    )