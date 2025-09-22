import os
import json
import boto3

sm_runtime = boto3.client('sagemaker-runtime')
sqs = boto3.client('sqs')

SQS_QUEUE_URL = os.environ.get('SQS_QUEUE_URL')
SAGEMAKER_ENDPOINT = os.environ.get('SAGEMAKER_ENDPOINT', '')

THRESHOLD = float(os.environ.get('SCORE_THRESHOLD', '0.5'))

def handler(event, context):
    try:
        body = event.get('body') or event
        if isinstance(body, str):
            payload = json.loads(body)
        else:
            payload = body

        # Transform payload into CSV expected by model (user must align this with training)
        features = [payload.get('feat1', 0), payload.get('feat2', 0), payload.get('feat3', 0)]
        csv_line = ",".join([str(x) for x in features])

        if SAGEMAKER_ENDPOINT:
            resp = sm_runtime.invoke_endpoint(EndpointName=SAGEMAKER_ENDPOINT, ContentType='text/csv', Body=csv_line)
            score = float(resp['Body'].read().decode('utf-8').strip())
        else:
            # Local/simple heuristic fallback when no SageMaker endpoint provided
            score = float(sum(features)) / (len(features) + 1)

        out = {"score": score}
        if score >= THRESHOLD and SQS_QUEUE_URL:
            msg = {"transaction": payload, "score": score}
            sqs.send_message(QueueUrl=SQS_QUEUE_URL, MessageBody=json.dumps(msg))

        return {'statusCode': 200, 'body': json.dumps(out), 'headers': {'Content-Type': 'application/json'}}
    except Exception as e:
        return {'statusCode': 500, 'body': json.dumps({'error': str(e)})}
