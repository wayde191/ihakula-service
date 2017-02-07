#!/usr/bin/env bash

docker stop ihakula-service || true
docker rm ihakula-service || true

docker run \
 --name ihakula-service \
 -p 8700:9395 \
 -itd \
 -v $(pwd):/home/NorthernHemisphere/ihakula-service/ \
 -w /home/NorthernHemisphere/ihakula-service/ \
 \
 ihakula/api-ruby:api_ruby \
 /bin/bash

docker cp ./docker/api/api_entry_point.sh ihakula-service:/usr/bin/api_entry_point.sh
docker exec ihakula-service /bin/bash -c /usr/bin/api_entry_point.sh