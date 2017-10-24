source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.6'
gem 'rails-api'

gem 'puma'

# We are not using the railtie because it comes to late,
# we are setting the logger in production.rb
gem 'rails_stdout_logging', require: 'rails_stdout_logging/rails'

# Database
gem 'pg', '~> 0.15'
gem 'will_paginate', '~> 3.0.6'

# Openstack
gem 'monsoon-openstack-auth',
    git: 'https://gitHub.***REMOVED*** /monsoon/monsoon-openstack-auth.git',
    branch: 'master'

gem 'active_model_serializers', '>= 0.10.0.rc4'

# Asynchronous jobs via postgres
gem 'que'
gem 'que-web' # at some point this should be remove and started standalone

# arc client
gem 'arc-client', git: 'https://github.com/sapcc/arc-client.git'

source 'https://gems.***REMOVED***' do
  gem 'gitmirror'
end

# Prometheus instrumentation
gem 'prometheus-client'

# Avoid g++ dependency https://github.com/knu/ruby-domain_name/issues/3
# unf is pulled in by the ruby-arc-client
gem 'unf', '>= 0.2.0beta2'
gem 'posix-spawn'

gem 'swift_client'

gem 'with_advisory_lock'

# Sentry crash reporting
gem 'sentry-raven'
gem 'httpclient' # The only faraday backend that handled no_proxy :|

group :development, :test do
  # annotate models with database schema
  gem 'annotate'
  # Avoid No route matches [GET] "/apple-touch-icon.png") errors
  gem 'quiet_safari'
  # load .env
  gem 'dotenv-rails'
  gem 'spring'

  # debugging
  gem 'pry-rails'

  # testing
  gem 'rspec-rails'
  gem 'rspec-activejob'
  gem 'json_matchers'
  gem 'factory_girl_rails'
  gem 'database_cleaner'
  gem 'capybara'

  #generate swagger.json from specs
  gem 'rswag-specs'
end

group :berkshelf do
  gem 'appbundler', require: false
  gem 'berkshelf', '~> 6.1.0', require: false
end
