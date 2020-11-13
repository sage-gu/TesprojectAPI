FROM python:3.7

LABEL "Maintainer"="sage.gu@ihealthlabs.com"
LABEL "Version"="1.0"

RUN apt-get update
RUN apt-get -y install git vim curl

RUN mkdir -p /workspace
WORKDIR /workspace/

COPY requirements.txt ./
RUN pip install -r requirements.txt

COPY . ./

CMD ["python", "upload.py"]