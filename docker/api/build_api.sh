#!/usr/bin/env bash
set -ex
echo "----------------------------------build docker image"
docker build -t api_ruby -f ./docker/api/Dockerfile .
echo "----------------------------------tag image"
docker tag api_ruby ihakula/api-ruby:api_ruby

docker login --username $DOCKER_USER --password $DOCKER_PASS
echo "----------------------------------push to hub"
docker push ihakula/api-ruby:api_ruby

