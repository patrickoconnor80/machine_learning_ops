import prefect
from prefect import flow, get_run_logger
from platform import node, platform, python_version
from prefect.orion.api.server import ORION_API_VERSION as API
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

@flow
def maintenance():
    version = prefect.__version__
    logger = get_run_logger()
    logger.info("Network: %s. Instance: %s. Agent is healthy ✅️", node(), platform())
    logger.info("Python = %s. API: %s. Prefect = %s 🚀", python_version(), API, version)


# if __name__ == "__main__":
#     maintenance()

deployment.apply()