import sys

from prefect import task, flow
from prefect import get_run_logger
from typing import Any
from prefect.deployments import Deployment
from prefect.blocks.core import Block
from prefect.orion.schemas.schedules import CronSchedule

storage = Block.load("s3/prod")
version = sys.argv[1]

@task
def say_hi(user_name: str, question: str, answer: Any) -> None:
    logger = get_run_logger()
    logger.info("Hello from Prefect, %s! 👋", user_name)
    logger.info("The answer to the %s question is %s! 🤖", question, answer)

@flow
def parametrized(
    user: str = "Marvin", question: str = "Ultimate", answer: Any = 42
) -> None:
    say_hi(user, question, answer)


deployment = Deployment.build_from_flow(
    flow=parametrized,
    name="parametrized-deployment",
    version=version,
    work_queue_name="mlops",
    storage=storage,
    schedule=(CronSchedule(cron="0 0 * * *", timezone="America/New_York"))
)

if __name__ == "__main__":
    deployment.apply()