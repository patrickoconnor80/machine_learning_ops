from prefect.deployments import Deployment
from prefect.blocks.core import Block
from prefect.orion.schemas.schedules import CronSchedule
from maintenance import maintenance

storage = Block.load("s3/prod")

deployment = Deployment.build_from_flow(
    flow=maintenance,
    name="maintenance-deployment",
    work_queue_name="mlops",
    storage=storage,
    schedule=(CronSchedule(cron="0 0 * * *", timezone="America/New_York"))
)

if __name__ == "__main__":
    deployment.apply()