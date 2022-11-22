import os

import boto3


def get_boto_client(service):
    if not _clients.get(service):
        _clients[service] = boto3.client(
            service,
            region_name='us-east-1',
            aws_access_key_id=os.environ.get('AWS_ACCESS_KEY_ID', ''),
            aws_secret_access_key=os.environ.get('AWS_SECRET_ACCESS_KEY', ''),
            aws_session_token=os.environ.get('AWS_SESSION_TOKEN', ''),
        )
    return _clients[service]


_clients = {}
