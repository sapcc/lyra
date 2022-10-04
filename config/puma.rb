# workers Integer(ENV['WEB_CONCURRENCY'] || 2)
# preload_app!

# https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#threads
# Puma allows you to configure your thread pool with a min and max setting, controlling the number of 
# threads each Puma instance uses. The min threads setting allows your application to spin down resources 
# when not under load. This feature is not needed on Heroku as your application can consume all of the 
# esources on a given dyno. We recommend setting min to equal max.
threads_count = Integer(ENV['MAX_THREADS'] || 10)
threads threads_count, threads_count

# http keep alive idle timeout
persistent_timeout Integer(ENV['PERSISTENT_TIMEOUT'] || 61 )

# rackup      DefaultRackup
port        ENV['PORT'] || 3000
environment ENV['RAILS_ENV'] || 'production'

on_worker_boot do
  # Worker specific setup for Rails 4.1+
  # See: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot
  ActiveRecord::Base.establish_connection
end

require 'puma/app/status'
activate_control_app 'tcp://127.0.0.1:7353', no_token: 'true'
