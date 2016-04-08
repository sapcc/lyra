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

# Openstack
gem 'monsoon-openstack-auth',
    git: 'git://gitHub.***REMOVED*** /monsoon/monsoon-openstack-auth.git',
    branch: 'master'

gem 'active_model_serializers', '>= 0.10.0.rc4'

# Asynchronous jobs via postgres
gem 'que'
gem 'que-web' # at some point this should be remove and started standalone

source 'https://gems.***REMOVED***' do
  gem 'ruby-arc-client'
  gem 'gitmirror'
end

# Avoid g++ dependency https://github.com/knu/ruby-domain_name/issues/3
# unf is pulled in by the ruby-arc-client
gem 'unf', '>= 0.2.0beta2'
gem 'posix-spawn'

gem 'swift_client'

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
end

group :development, :test do
  # annotate models with database schema
  gem 'annotate'
  # Avoid No route matches [GET] "/apple-touch-icon.png") errors
  gem 'quiet_safari'
  # load .env
  gem 'dotenv-rails'
  # Call 'byebug' anywhere in the code to stop execution and get a console
  gem 'byebug'
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
end

group :berkshelf do
  gem 'appbundler', require: false
  gem 'berkshelf', require: false
end

