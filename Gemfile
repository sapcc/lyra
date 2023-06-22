# frozen_string_literal: true

source 'https://rubygems.org'

ruby '2.4.10'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '5.2.2.1'
# removed rails-api because of https://github.com/rails-api/rails-api/issues/218

gem 'puma'

# We are not using the railtie because it comes to late,
# we are setting the logger in production.rb
gem 'rails_stdout_logging', require: 'rails_stdout_logging/rails'

# Database
gem 'pg', '~> 0.15'
gem 'will_paginate', '~> 3.0.6'

# Openstack
gem 'monsoon-openstack-auth',
    git: 'https://github.com/sapcc/monsoon-openstack-auth.git',
    branch: 'master'

gem 'active_model_serializers', '>= 0.10.0.rc4'

# Asynchronous jobs via postgres
# before upgrading to version 1.3.0 there is an action required see here
# https://github.com/que-rb/que/blob/master/CHANGELOG.md#130-2022-02-25
gem 'que', '1.2.0'
gem 'que-web' # at some point this should be remove and started standalone

# arc client
gem 'arc-client', git: 'https://github.com/sapcc/arc-client.git'

gem 'gitmirror'

# Prometheus instrumentation
gem 'prometheus-client', '~>0.10.0'

# Avoid g++ dependency https://github.com/knu/ruby-domain_name/issues/3
# unf is pulled in by the ruby-arc-client
gem 'unf', '>= 0.2.0beta2'
gem 'posix-spawn'

gem 'swift_client', '>= 0.1.6'

gem 'with_advisory_lock'

# Sentry crash reporting
gem 'sentry-raven'
gem 'httpclient' # The only faraday backend that handled no_proxy :|

gem 'ffi-libarchive'

# https://nvd.nist.gov/vuln/detail/CVE-2019-5477
gem 'nokogiri', '>= 1.10.4'

group :development, :test do
  # annotate models with database schema
  gem 'annotate'
  # Avoid No route matches [GET] "/apple-touch-icon.png") errors
  gem 'quiet_safari'
  # load .env
  gem 'dotenv-rails'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'

  # debugging
  gem 'pry-rails'

  # testing
  gem 'rspec-rails'
  # gem 'rspec-activejob' deprecated Since v3.5, rspec-rails defines matchers that provide the same functionality as those in rspec-activejob. See rspec-rails docs for more detail.
  gem 'json_matchers'
  gem 'factory_girl_rails'
  # upgraded because of error https://github.com/DatabaseCleaner/database_cleaner/issues/476
  gem 'database_cleaner', '~>1.6.0'
  gem 'capybara'

  # generate swagger.json from specs
  gem 'rswag-specs'
end

group :berkshelf do
  gem 'appbundler', '~> 0.7.0', require: false
  gem 'berkshelf', '~> 7.0.1', require: false
end
