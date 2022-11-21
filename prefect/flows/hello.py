from prefect import task, flow
from prefect import get_run_logger
import os 
from prefect.deployments import Deployment
from prefect.blocks.core import Block
from prefect.orion.schemas.schedules import CronSchedule

print(os.path.dirname(os.path.realpath(__file__)))
print(os.getcwd())

#from prefect.libs.healthcheck import healthcheck  # to show how subflows can be packaged and imported

@task
def say_hi(user_name: str):
    logger = get_run_logger()
    logger.info("Hello from Prefect 2.0, %s!", user_name)


@flow
def hello(user: str = "Marvin"):
    say_hi(user)
    #healthcheck()


storage = Block.load("s3/prod")

deployment = Deployment.build_from_flow(
    flow=hello,
    name="hello-deployment",
    work_queue_name="mlops",
    storage=storage,
    schedule=(CronSchedule(cron="0 0 * * *", timezone="America/New_York"))
)

if __name__ == "__main__":
    deployment.apply()