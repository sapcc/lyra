# active_job.queue_adapter is set in application.rb, overridden in environments/*.rb

Que.logger = Rails.logger
# Start some Que workers in development (when running 'rails s')
if Rails.env.development? && defined? Rails::Server
  # Silence Que workers in rails server
  Que.log_formatter = proc do |data|
    if data[:event] == :job_unavailable
      nil
    else
      JSON.dump(data)
    end

    puts 'Start Que running "bundle exec que --log-internals"'
  end
  # Due to popular demand, the default queue name is now "default" rather than an empty string.
  # Que.queue_name = 'default'

  # Que's implementation has been changed from one in which worker threads hold their own PG connections and lock their own jobs to one in which a single thread (and PG connection) locks jobs through LISTEN/NOTIFY and batch polling, and passes jobs along to worker threads.
  # The following methods are not meaningful under the new implementation and have been removed
  # Que.worker_count getter and sette
  # The mode setter has been removed.
  # Que.worker_count = 2
  # Que.mode = :async
end
