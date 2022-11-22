import sys

import platform
import prefect
from prefect import task, flow, get_run_logger
from prefect.orion.api.server import ORION_API_VERSION
from prefect.deployments import Deployment
from prefect.blocks.core import Block
from prefect.orion.schemas.schedules import CronSchedule
from prefect_aws.ecs import ECSTask
          
ecs = ECSTask.load("prod")
storage = Block.load("s3/prod")
version = sys.argv[1]

@task
def log_platform_info():
    logger = get_run_logger()
    logger.info("Host's network name = %s", platform.node())
    logger.info("Python version = %s", platform.python_version())
    logger.info("Platform information (instance type) = %s ", platform.platform())
    logger.info("OS/Arch = %s/%s", sys.platform, platform.machine())
    logger.info("Prefect Version = %s 🚀", prefect.__version__)
    logger.info("Prefect API Version = %s", ORION_API_VERSION)

@flow
def healthcheck():
    log_platform_info()


deployment = Deployment.build_from_flow(
    flow=healthcheck,
    name="healthcheck-deployment",
    version=version,
    work_queue_name="mlops",
    storage=storage,
    infrastructure=ecs,
    schedule=(CronSchedule(cron="0 0 * * *", timezone="America/New_York")),
    output="prefect/flows/config_output/healthcheck.yaml"
)

if __name__ == "__main__":
    deployment.apply()