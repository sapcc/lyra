namespace :run do
  desc 'Clear run executions older than expiry_period keeping keep_minimum'
  task :cleanup, %i[expiry_period keep_minimum] => :environment do |_task, args|
    args.with_defaults(keep_minimum: 5)
    args.with_defaults(expiry_period: 30)

    # don't make offset negative
    offset = args.keep_minimum > 0 ? args.keep_minimum - 1 : args.keep_minimum
    query = "DELETE FROM runs WHERE created_at < (SELECT created_at FROM runs WHERE created_at < '#{args.expiry_period.days.ago}' ORDER BY created_at DESC OFFSET #{offset} ROWS LIMIT 1)"
    result = ActiveRecord::Base.connection.execute(query)
    Rails.logger.info "Cleanup runs: #{result.cmd_status} affected rows #{result.cmd_tuples}"
  end
end
