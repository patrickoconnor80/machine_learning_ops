import platform
import prefect
from prefect import task, flow, get_run_logger
from prefect.orion.api.server import ORION_API_VERSION
import sys
from log_flow import log_flow
from prefect.deployments import Deployment

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
    name="log-simple",
    parameters={"name": "Marvin"},
    infra_overrides={"env": {"PREFECT_LOGGING_LEVEL": "DEBUG"}},
    work_queue_name="test",
    schedule=,
    storage=
)

if __name__ == "__main__":
    deployment.apply()
