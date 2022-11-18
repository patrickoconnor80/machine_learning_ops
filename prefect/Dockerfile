FROM prefecthq/prefect:2-python3.9
RUN /usr/local/bin/python -m pip install --upgrade pip
WORKDIR /opt/prefect
COPY requirements.txt .
COPY libs/ /opt/prefect/flows/libs/
COPY flows/ /opt/prefect/flows/
RUN pip install -r requirements.txt
RUN prefect block register -m prefect_aws.ecs