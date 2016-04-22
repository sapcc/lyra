#workers Integer(ENV['WEB_CONCURRENCY'] || 2)
#preload_app!

threads_count = Integer(ENV['MAX_THREADS'] || 10)
threads threads_count, threads_count


#rackup      DefaultRackup
port        ENV['PORT'] || 3000 
environment ENV['RAILS_ENV'] || 'production'

on_worker_boot do
  # Worker specific setup for Rails 4.1+
  # See: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot
  ActiveRecord::Base.establish_connection
end
