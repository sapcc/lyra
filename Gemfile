source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.5'
gem 'rails-api'

# Database
gem 'pg', '~> 0.15'

# Openstack
gem 'monsoon-openstack-auth', git: 'git://gitHub.***REMOVED*** /monsoon/monsoon-openstack-auth.git', branch: 'no-fog' 

#JSON
gem 'jbuilder', '~> 2.0'

group :development, :test do
  gem 'annotate'
  #Avoid No route matches [GET] "/apple-touch-icon.png") errors 
  gem 'quiet_safari'
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

