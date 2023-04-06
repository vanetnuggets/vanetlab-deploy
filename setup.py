#!/bin/sh
# TODO the same but `.bat` for our beloved windows fans
git clone https://github.com/vanetnuggets/vanetlab-be
git clone https://github.com/vanetnuggets/vanetlab-ns3

docker-compose up -d
docker-compose run --rm app
