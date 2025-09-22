import os
import boto3
import io
import pandas as pd
import numpy as np

s3 = boto3.client('s3')
PROCESSED_PREFIX = os.environ.get('PROCESSED_PREFIX', 'processed/')

def handler(event, context):
    print("Preprocess event:", event)
    rec = event['Records'][0]
    bucket = rec['s3']['bucket']['name']
    key = rec['s3']['object']['key']

    obj = s3.get_object(Bucket=bucket, Key=key)
    body = obj['Body'].read()
    df = pd.read_csv(io.BytesIO(body))

    if 'transaction_time' in df.columns:
        df['transaction_time'] = pd.to_datetime(df['transaction_time'], errors='coerce')
        df['hour'] = df['transaction_time'].dt.hour.fillna(0).astype(int)
    if 'amount' in df.columns:
        df['amount_log'] = (df['amount'].fillna(0) + 1).apply(lambda x: np.log(x))

    df = df.fillna(0)

    processed_key = PROCESSED_PREFIX + key.split('/')[-1]
    out_buffer = io.StringIO()
    df.to_csv(out_buffer, index=False)
    s3.put_object(Bucket=bucket, Key=processed_key, Body=out_buffer.getvalue().encode('utf-8'))
    return {'status': 'ok', 'processed_key': processed_key}
