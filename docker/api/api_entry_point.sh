#!/usr/bin/env bash
set -ex

cd /home/NorthernHemisphere/ihakula-service
bundle install --path ./vendor/bundle --binstubs
bundle exec unicorn -c /home/NorthernHemisphere/ihakula-service/conf/unicorn.rb -E development -D
service nginx restart
