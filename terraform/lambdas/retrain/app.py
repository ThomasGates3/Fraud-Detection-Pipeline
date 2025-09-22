import os
import boto3
import time

sagemaker = boto3.client('sagemaker')
s3 = boto3.client('s3')

ROLE = os.environ.get('SAGEMAKER_ROLE_ARN', '')
BUCKET = os.environ.get('BUCKET', '')

def make_training_job_name():
    return "fraud-train-" + str(int(time.time()))

def handler(event, context):
    # This lambda is a basic starter to call create_training_job; you will need to provide TRAINING_IMAGE and other params.
    training_job_name = make_training_job_name()
    train_s3_uri = f"s3://{BUCKET}/processed/"

    # Minimal example: user must customize TrainingImage and hyperparameters
    response = {
        'started': training_job_name,
        'train_s3_uri': train_s3_uri
    }
    return response
