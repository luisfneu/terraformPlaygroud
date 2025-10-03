import boto3
import json
import os

def lambda_handler(event, context):
    kms = boto3.client('kms')

    alias_name = event.get('alias', 'lambida-key')

    response = kms.create_key(
        KeyUsage='ENCRYPT_DECRYPT',
        Origin='AWS_KMS'
    )
    key_id = response['KeyMetadata']['KeyId']

    kms.create_alias(
        AliasName=f'alias/{alias_name}',
        TargetKeyId=key_id
    )

    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': f'success!',
            'KeyId': key_id,
            'Alias': alias_name
        })
    }
