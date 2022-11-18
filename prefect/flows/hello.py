from prefect import task, flow
from prefect import get_run_logger
from prefect.flows.healthcheck import healthcheck  # to show how subflows can be packaged and imported

import os 
dir_path = os.path.dirname(os.path.realpath(__file__))
print(dir_path)
@task
def say_hi(user_name: str):
    logger = get_run_logger()
    logger.info("Hello from Prefect 2.0, %s!", user_name)


@flow
def hello(user: str = "Marvin"):
    say_hi(user)
    healthcheck()


if __name__ == "__main__":
    hello(user="Anna")
