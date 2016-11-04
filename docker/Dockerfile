FROM hub.***REMOVED***/monsoon/alpine:3.3
ADD docker/monsoon.rsa.pub /etc/apk/keys/monsoon.rsa.pub
RUN echo "https://alpine-packages.***REMOVED***" >> /etc/apk/repositories
RUN { \
		echo 'install: --no-document'; \
		echo 'update: --no-document'; \
	  } >> /etc/gemrc
RUN apk --no-cache add git curl tzdata \
                   # ruby base
                   ruby ruby-json ruby-bigdecimal ruby-irb ruby-io-console \
                   # gems with native extensions
                   ruby-byebug \
                   ruby-hitimes \
                   ruby-nio4r \
                   ruby-nokogiri \
                   ruby-pg \
                   ruby-posix-spawn \
                   ruby-puma \
                   ruby-thread_safe

# install psql and pg_dump
# pg_dump is part the "postgresql" server package on alpine. 
# so we install the package, copy the binary and uninstall :)
RUN apk --no-cache add postgresql postgresql-client && \
    cp /usr/bin/pg_dump /tmp/pg_dump && \
    apk del postgresql && \
    mv /tmp/pg_dump /usr/bin/pg_dump

RUN curl -L -o /usr/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.0.1/dumb-init_1.0.1_amd64 && \
    chmod +x /usr/bin/dumb-init && \
    dumb-init -V

WORKDIR /home/app/webapp

RUN gem install bundler -v 1.11.2
ADD Gemfile Gemfile.lock ./
RUN bundle install --without development

#appbundle berks
RUN ln -s /home/app/webapp /tmp/berkshelf && \
    appbundler /tmp/berkshelf /usr/local/bin && \
    rm /tmp/berkshelf && \
    berks -v
ADD . /home/app/webapp/

#temporary fix for this bug https://github.com/bundler/bundler/pull/4369
#can be removed when bundler > 1.11.2
RUN sed -i -e 's/def_delegators :@specs, :<<, :length, :add, :remove/def_delegators :@specs, :<<, :length, :add, :remove, :size/' /usr/lib/ruby/gems/2.3.0/gems/bundler-1.11.2/lib/bundler/spec_set.rb

ENTRYPOINT ["dumb-init", "-c", "--", "docker/env.sh"]
CMD ["docker/start.sh"]
