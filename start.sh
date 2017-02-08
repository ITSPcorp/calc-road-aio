#!/bin/bash

mongod --fork --logpath /var/log/mongodb/mongo.log

cd /home/itsp/calc-road/template

pm2 start server.js

cd ../import_IA

python server.py