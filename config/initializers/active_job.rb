Rails.configuration.active_job.queue_adapter = :que

#Start some Que workers in development (when running 'rails s') 
if Rails.env.development? && defined? Rails::Server
  #Silence Que workers in rails server
  Que.log_formatter = proc do |data|
    if data[:event] == :job_unavailable 
      nil
    else
      JSON.dump(data)
    end
  end
  Que.queue_name = 'default'
  Que.worker_count = 2
  puts "Starting #{Que.worker_count} Que background worker"
  Que.mode = :async
end
