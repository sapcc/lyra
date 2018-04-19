namespace :run do
  desc 'Clear runs'
  task :cleanup, %i[expiry_period keep_minimum] => :environment do |_task, args|
    args.with_defaults(keep_minimum: 5)
    args.with_defaults(expiry_period: 30)
    Run.where('updated_at < ?', args.expiry_period.days.ago).order('updated_at desc').offset(args.keep_minimum).destroy_all
  end
end
