#!/usr/bin/env bash

export DB_PORT_3306_TCP_ADDR=127.0.0.1

docker stop ihakula-service || true
docker rm ihakula-service || true

docker run \
 --name ihakula-service \
 -p 8801:9395 \
 --link local-zm-mysql:db \
 -itd \
 -v $(pwd):/home/NorthernHemisphere/ihakula-service/ \
 -w /home/NorthernHemisphere/ihakula-service/ \
 \
 ihakula/api-ruby:api_ruby \
 /bin/bash

docker cp ./docker/api/api_entry_point.sh ihakula-service:/usr/bin/api_entry_point.sh
docker exec ihakula-service /bin/bash -c /usr/bin/api_entry_point.sh

#docker run --name local-zm-mysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=Wayde191! -d mysql:5.6
#docker run --name local-zm-phpmyadmin -d --link local-zm-mysql:db -p 8601:80 phpmyadmin/phpmyadmin
#
#mysql -h 127.0.0.1 -P 3306 --protocol=tcp -u root -p
