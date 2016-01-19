source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.5'
gem 'rails-api'

# Database
gem 'pg', '~> 0.15'

# Openstack
gem 'monsoon-fog', git: 'git://gitHub.***REMOVED*** /monsoon/monsoon-fog.git', :ref => '52f4b2'
gem 'fog', git: 'git://gitHub.***REMOVED*** /monsoon/fog.git', branch:'master', :ref => 'b3c62'
gem 'monsoon-openstack-auth', git: 'git://gitHub.***REMOVED*** /monsoon/monsoon-openstack-auth.git', branch: :master
gem 'net-ssh' # needed because fog do not required the gem but fog use it

#JSON
gem 'jbuilder', '~> 2.0'

group :development, :test do
  # load .env
  gem 'dotenv-rails'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  # debugging
  gem 'pry-rails'

  # testing
  gem "rspec-rails"
  gem "factory_girl_rails"
  gem "database_cleaner"
  gem "capybara"
end

