#!/bin/bash

service mongodb start

cd /home/itsp/calc-road/template

pm2 start server.js

cd ../import_IA

python server.py