import sys
sys.path.insert(1, '/home/runner/work/machine_learning_ops/machine_learning_ops/prefect/flows')

from prefect.deployments import Deployment
from prefect.blocks.core import Block
from prefect.orion.schemas.schedules import CronSchedule
from hello import hello

version = sys.argv[1]

storage = Block.load("s3/prod")

deployment = Deployment.build_from_flow(
    flow=hello,
    name="hello-deployment",
    work_queue_name="mlops",
    version=version,
    storage=storage,
    schedule=(CronSchedule(cron="0 0 * * *", timezone="America/New_York"))
)

if __name__ == "__main__":
    deployment.apply()