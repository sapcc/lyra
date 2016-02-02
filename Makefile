SHELL       := /bin/sh
REPOSITORY  := docker.***REMOVED***/monsoon/monsoon-automation
TAG         ?= latest
IMAGE       := $(REPOSITORY):$(TAG)
DB_IMAGE    := docker.***REMOVED***/monsoon/postgres:9.4-alpine

### Executables
DOCKER      = docker
WAIT        = $(DOCKER) run --rm --link $(WAIT_ID):wait docker.***REMOVED***/monsoon-docker/wait || ($(DOCKER) logs $(WAIT_ID) && false)
#MTIMES      = $(DOCKER) run --rm $(MTIMES_OPTS)         $(BUILD_IMAGE) reset_mtimes

### Variables that are expanded dynamically
postgres = $(shell cat postgres 2> /dev/null)
webapp   = $(shell cat webapp 2> /dev/null)

# ----------------------------------------------------------------------------------
#   image 
# ----------------------------------------------------------------------------------
#image: build precompile
image: build
	echo $(IMAGE) > image

# ----------------------------------------------------------------------------------
#   build 
# ----------------------------------------------------------------------------------
#
# Build and tags an image from a Dockerfile.
#
# We need to reset the modification times of all files in a git repository to the 
# date of the latest commit that changed it. This is required because Docker takes 
# the mtime of a file into account when checking for modifications. Git on the other
# hand does not. Without this the cache will be busted by Git and is basically
# useless.
#
#build: MTIMES_OPTS = -v $(shell pwd):/src
build: 
	#$(MTIMES)
	$(DOCKER) pull $(REPOSITORY):build.latest || true
	$(DOCKER) build -f docker/Dockerfile -t $(IMAGE) --rm . 

# ----------------------------------------------------------------------------------
#   precompile 
# ----------------------------------------------------------------------------------
#
# Precompiles the assets for this application. 
#
# In order to do so we first need to start the application container. Then we
# execute the precompile rake task.  And finally we commit and tag the
# resulting container, which now contains all precompiled assets.
#
precompile: webapp
	$(DOCKER) exec $(webapp) \
		env RAILS_ENV=production bundle exec rake assets:precompile
	$(DOCKER) commit $(webapp) $(IMAGE) > precompile

# ----------------------------------------------------------------------------------
#   test 
# ----------------------------------------------------------------------------------
#
# Runs all unit tests suits.
#
.PHONY: 
test: rspec

# ----------------------------------------------------------------------------------
#   rspec 
# ----------------------------------------------------------------------------------
#
# Runs the rspec test suit. Requires the postgres db to be started and
# prepared. 
#
.PHONY: 
rspec: postgres migrate-test
	$(DOCKER) run --rm --link $(postgres):postgres $(IMAGE) \
		bundle exec rspec 

# ----------------------------------------------------------------------------------
#   webapp 
# ----------------------------------------------------------------------------------
#
# Start the application and its required containers. Waits until it is
# listening on port 80
#
webapp: WAIT_ID = $$(cat webapp)
webapp: WAIT_OPTS = -p 80
webapp: migrate-production
	$(DOCKER) run --link $(postgres):postgres -d $(IMAGE) > webapp 
	$(WAIT)

# ----------------------------------------------------------------------------------
#   postgres 
# ----------------------------------------------------------------------------------
#
# Start postgres database and wait for it to become available. 
#
postgres: WAIT_ID = $$(cat postgres)
postgres: WAIT_OPTS =
postgres: 
	$(DOCKER) run -d $(DB_IMAGE) > postgres 
	$(WAIT)

# ----------------------------------------------------------------------------------
#   migrate-%
# ----------------------------------------------------------------------------------
#
# Prepare the database by running the db tasks for the given environment. 
#
.PHONY: 
migrate-%: postgres 
	$(DOCKER) run --rm --link $(postgres):postgres -e RAILS_ENV=$* $(IMAGE) \
		bundle exec rake db:setup db:migrate db:seed

# ----------------------------------------------------------------------------------
#   clean 
# ----------------------------------------------------------------------------------
#
# Kill and remove all containers. Remove intermediate files. 
#
.PHONY: 
clean: 	
	$(DOCKER) rm -f $(postgres) $(webapp) &> /dev/null || true
	$(RM) image build precompile webapp postgres
