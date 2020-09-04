FROM  ruby:2.4-alpine3.7
LABEL source_repository="https://github.com/sapcc/lyra"

# pg_dump is part the "postgresql" server package on alpine.
RUN apk --no-cache add git curl tzdata postgresql postgresql-client libarchive-dev

RUN apk --no-cache add build-base postgresql-dev --virtual .builddeps \
      && gem install hitimes -v 1.2.5 \
      && gem install nio4r -v 2.3.1 \
      && gem install nokogiri -v 1.10.4 \
      && gem install pg -v 0.18.4 \
      && gem install posix-spawn -v 0.3.13 \
      && gem install puma -v 3.11.4  \
      && gem install thread_safe -v 0.3.5 \
      && gem install ffi -v 1.9.24 \
      && gem install websocket-driver -v 0.7.0 \
      && gem install json -v 1.8.6 \
      && gem install libyajl2 -v 1.2.0 \
      && gem install ffi-yajl -v 2.3.1 \
      && runDeps="$( \
		      scanelf --needed --nobanner --recursive /usr/local \
            | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
            | sort -u \
            | xargs -r apk info --installed \
            | sort -u \
          )" \
      && apk add --virtual .rundeps $runDeps \
      && apk del .builddeps \
      && gem sources -c \
      && rm -f /usr/local/bundle/cache/*

ADD docker/certs/*.crt /usr/local/share/ca-certificates/
RUN update-ca-certificates

RUN curl -L -o /usr/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64 && \
    chmod +x /usr/bin/dumb-init && \
    dumb-init -V

WORKDIR /home/app/webapp

RUN gem update --system && gem install bundler -v 2.0.1
ENV BUNDLER_VERSION 2.0.1
ADD Gemfile Gemfile.lock ./
RUN bundle install --without development

#appbundle berks
RUN ln -s /home/app/webapp /tmp/berkshelf  \
    && appbundler /tmp/berkshelf /usr/local/bin  \
    && rm /tmp/berkshelf  \
    && rm -f /usr/local/bundle/bin/berks \
    berks -v
ADD . /home/app/webapp/

RUN bundle exec rake rswag:specs:swaggerize

ENTRYPOINT ["dumb-init", "-c", "--", "docker/env.sh"]
CMD ["docker/start.sh"]
