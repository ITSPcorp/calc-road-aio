########################################
#   Docker container for Calc-road 
########################################
#
# Maintained by Valentin Boucher
# Build:
#    $ docker build -t itsp/calc-road-aio:tag .
#
# Execution:
#    $ docker run -t -i \
#      itsp/calc-road-aio /bin/bash
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
#

FROM ubuntu:14.04
MAINTAINER Valentin Boucher <boucherv@live.fr>
LABEL version="0.1" description="Calc-road AIO Docker container"

RUN mkdir /home/itsp
WORKDIR /home/itsp


# Packaged dependencies
RUN apt update && apt install -y \
curl \
git \
build-essential \
python-dev \
python-pip \
protobuf-compiler \
libprotobuf-dev \
libtokyocabinet-dev \
python-psycopg2 \
libgeos-c1 \
libzmq-dev \
--no-install-recommends

RUN curl -sL https://deb.nodesource.com/setup_7.x | sudo -E bash -

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6
RUN echo "deb http://repo.mongodb.org/apt/ubuntu "$(lsb_release -sc)"/mongodb-org/3.4 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.4.list

RUN apt update && apt install -y \
nodejs \
mongodb-org

RUN mkdir -p /data/db

RUN pip install --upgrade pip

ADD ./calc-road/ ./calc-road/

WORKDIR /home/itsp/calc-road

RUN pip install -r import_IA/requierements.pip 

ADD indexes.js database/indexes.js

RUN mongod --fork --logpath /var/log/mongodb/mongo.log && \
	sleep 60 && \
	mongoimport  --db calc_road --collection user --file  database/db-default_user.json && \
	mongoimport  --db calc_road --collection config --file  database/db-default_config.json && \
	mongo database/indexes.js

ADD config.json template/config.json
ADD config.json import_IA/config.json



WORKDIR /home/itsp/calc-road/template

RUN npm install ./ 

RUN npm install zerorpc

RUN npm install -g bower pm2 

RUN bower install --allow-root

WORKDIR /home/itsp/calc-road/

ADD start.sh start.sh

RUN chmod 777 start.sh

CMD /home/itsp/calc-road/start.sh


