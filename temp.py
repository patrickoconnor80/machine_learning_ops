from prefect.filesystems import S3
from prefect_aws.ecs import ECSTask, AwsCredentials

id_ = "${{ secrets.AWS_ACCESS_KEY_ID }}"
key_ = "${{ secrets.AWS_SECRET_ACCESS_KEY }}"
path_ = "${{ github.event.inputs.s3_path }}"
img_ = "${{ needs.ecr-repo.outputs.image }}"
block_ = "$BLOCK"
cluster_ = "${{ env.ECS_CLUSTER }}"
cpu_ = "${{ github.event.inputs.cpu }}"
memory_ = "${{ github.event.inputs.memory }}"
aws_acc_id = "$AWS_ACCOUNT_ID"
exec_role = f"arn:aws:iam::{aws_acc_id}:role/dataflowops_ecs_execution_role"
task_role = f"arn:aws:iam::{aws_acc_id}:role/dataflowops_ecs_execution_role"

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