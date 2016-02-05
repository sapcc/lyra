FROM ruby:2.3-slim

ENV http_proxy=http://proxy.***REMOVED***:8080 \
    https_proxy=http://proxy.***REMOVED***:8080 \
    no_proxy=***REMOVED***,127.0.0.1,localhost

RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    apt-get update && \
    apt-get remove -y --purge postgresql-client postgresql-client-9.3 postgresql-client-common && \
    apt-get install -y gcc git make postgresql-client-9.5 libpq-dev && \
    rm -rf /var/lib/apt/lists/*

RUN curl -L -o /usr/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.0.0/dumb-init_1.0.0_amd64 && \
    chmod +x /usr/bin/dumb-init && \
    dumb-init -V
ENTRYPOINT ["dumb-init", "-c", "--", "env.sh"]
RUN useradd -ms /bin/bash app
WORKDIR /home/app/webapp
ADD Gemfile Gemfile.lock ./
RUN bundle install --system
ADD . /home/app/webapp/
USER app
CMD ["puma", "-C", "config/puma.rb"]
