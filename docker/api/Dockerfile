FROM ihakula/go-agent:latest

RUN apt-get -y install libmysqlclient-dev

# copy file
WORKDIR /home/NorthernHemisphere/ihakula-service/
COPY ./conf/nginx.conf /etc/nginx/sites-enabled/default
COPY ./docker/api/api_entry_point.sh /usr/local/bin
COPY ./Gemfile /home/NorthernHemisphere/ihakula-service/Gemfile
COPY ./Gemfile.lock /home/NorthernHemisphere/ihakula-service/Gemfile.lock

RUN bundle install --path ./vendor/bundle --binstubs

#ENTRYPOINT ["api_entry_point.sh"]