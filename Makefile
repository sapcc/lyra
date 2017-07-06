SHELL       := /bin/sh
REPOSITORY  := hub.***REMOVED***/monsoon/lyra
TAG         ?= latest
IMAGE       := $(REPOSITORY):$(TAG)

ifneq ($(http_proxy),)
BUILD_ARGS+= --build-arg http_proxy=$(http_proxy) --build-arg https_proxy=$(https_proxy) --build-arg no_proxy=$(no_proxy)
endif
ifneq ($(NO_CACHE),)
BUILD_ARGS += --no-cache
endif

build:
	docker build $(BUILD_ARGS) -f docker/Dockerfile -t $(IMAGE) .

test:
	docker run -v $$(PWD)/ci:/ci $(IMAGE) sh -c " \
	apk add --no-cache postgresql bash; \
	su postgres -c '/ci/scripts/pg_tmp.sh -p 5432 -l 127.0.0.1 -w 300 -d /tmp/pg start'; \
	rake db:create db:migrate RAILS_ENV=test; \
	bundle exec rspec \
	"
