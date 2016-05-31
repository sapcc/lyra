require 'swift'
module AutomationBase
  extend ActiveSupport::Concern

  included do

    attr_reader :run

    rescue_from(StandardError) do |exception|
      bt = Rails.backtrace_cleaner.clean(exception.backtrace)
      msg = "#{exception.message}:\n" + bt.join("\n")
      logger.error msg 
      run.log msg 
      run.update!(state: 'failed')
    end

    before_perform do |job|
      logger.info "Running #{self.class.to_s} for automation(id=#{job.arguments[2].id rescue "unknown"})" 
      @run = Run.find_by_job_id!(job.job_id)
    end
  end

  def execute(command)
    out = `#{command} 2>&1` 
    raise "Executing [#{command}] failed (#{$?.exitstatus}):\n#{out}" if $?.exitstatus != 0
    out
  end

  def artifact_key(sha)
    "#{sha}-#{self.class.to_s.downcase.gsub(/automation|job/, "")}"
  end

  def tarball_published?(sha)
    Swift.client.head_object(artifact_key(sha), "monsoon-automation")
    return true
  rescue SwiftClient::ResponseError
    return false
  end

  def publish_tarball(path)
    objectname = File.basename(path)
    human_size = ActiveSupport::NumberHelper::NumberToHumanSizeConverter.new(File.size?(path),{}).convert rescue ""
    run.log("Uploading #{objectname} (#{human_size})...\n")
    File.open(path, "r") do |f|
      Swift.client.put_object objectname, f, "monsoon-automation", {"Content-Type" => 'application/gzip'}
      Swift.client.temp_url objectname, "monsoon-automation"
    end
  end
  
end
