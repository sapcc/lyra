FROM docker.***REMOVED***/monsoon/docker-passenger-rails-ruby22:1.17.4

RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    apt-get update && \
    apt-get remove -y --purge postgresql-client postgresql-client-9.3 postgresql-client-common && \
    apt-get install -y postgresql-client-9.5 && \
    rm -rf /var/lib/apt/lists/*


WORKDIR /home/app/webapp
ADD Gemfile ./
ADD Gemfile.lock ./

RUN bundle install --system

ADD docker/environment.conf /etc/nginx/main.d/
ADD . /home/app/webapp/
