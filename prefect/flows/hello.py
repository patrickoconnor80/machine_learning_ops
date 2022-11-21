import sys
import os 

from prefect import task, flow
from prefect import get_run_logger
from prefect.deployments import Deployment
from prefect.blocks.core import Block
from prefect.orion.schemas.schedules import CronSchedule

print(os.getcwd())

storage = Block.load("s3/prod")
version = sys.argv[1]

@task
def say_hi(user_name: str):
    logger = get_run_logger()
    logger.info("Hello from Prefect 2.0, %s!", user_name)

@flow
def hello(user: str = "Marvin"):
    say_hi(user)
    #healthcheck()


deployment = Deployment.build_from_flow(
    flow=hello,
    name="hello-deployment",
    version=version,
    work_queue_name="mlops",
    storage=storage,
    schedule=(CronSchedule(cron="0 0 * * *", timezone="America/New_York"))
)

if __name__ == "__main__":
    deployment.apply()

from prefect.libs.snowflake_client import SnowflakeClient