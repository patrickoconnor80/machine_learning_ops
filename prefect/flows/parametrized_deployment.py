import sys
from prefect.deployments import Deployment
from prefect.blocks.core import Block
from prefect.orion.schemas.schedules import CronSchedule
from parametrized import parametrized

version = sys.argv[0]

storage = Block.load("s3/prod")

deployment = Deployment.build_from_flow(
    flow=parametrized,
    name="parametrized-deployment",
    work_queue_name="mlops",
    version=version,
    storage=storage,
    schedule=(CronSchedule(cron="0 0 * * *", timezone="America/New_York"))
)

if __name__ == "__main__":
    deployment.apply()