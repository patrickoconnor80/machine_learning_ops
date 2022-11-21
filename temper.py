from prefect.filesystems import S3
from prefect_aws.ecs import ECSTask, AwsCredentials


id_ = "AKIA5ZPIWBHPCTT2WVP2"
key_ = "wdmJ7G5r+2bW5gcEQWrw22b3zGDVWZBtLLm4RJjd"
path_ = "prefect-orion-storage-8"
img_ = "mlops"
block_ = "prod"
cluster_ = "mlops"
cpu_ = "256"
memory_ = "512"
aws_acc_id = "948065143262"
exec_role = f"arn:aws:iam::{aws_acc_id}:role/{img_}-TaskRole"
task_role = f"arn:aws:iam::{aws_acc_id}:role/{img_}-TaskExecutionRole"

aws_creds = AwsCredentials(aws_access_key_id=id_, aws_secret_access_key=key_)
aws_creds.save(block_, overwrite=True)

s3 = S3(bucket_path=path_, aws_access_key_id=id_, aws_secret_access_key=key_)
s3.save(block_, overwrite=True)

ecs = ECSTask(
    aws_credentials=aws_creds,
    image=img_,
    cpu=cpu_,
    memory=memory_,
    stream_output=True,
    configure_cloudwatch_logs=True,
    cluster=cluster_,
    execution_role_arn=exec_role,
    task_role_arn=task_role,
)
ecs.save(block_, overwrite=True)

