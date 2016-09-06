require 'swift'
module AutomationBase
  extend ActiveSupport::Concern

  included do

    attr_reader :run

    rescue_from(StandardError) do |exception|
      bt = Rails.backtrace_cleaner.clean(exception.backtrace)
      msg = "<#{exception.class}> #{exception.to_s}:\n" + bt.join("\n")
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

  def artifact_name(sha)
    "#{sha}-#{self.class.to_s.downcase.gsub(/automation|job/, "")}.tgz"
  end

  def artifact_published?(name)
    Swift.client.head_object(name, Swift.container)
    return true
  rescue SwiftClient::ResponseError
    return false
  end

  def artifact_url(name)
    Swift.client.temp_url name, "automation-artifacts"
  end

  def publish_artifact(path, name)
    human_size = ActiveSupport::NumberHelper::NumberToHumanSizeConverter.new(File.size?(path),{}).convert rescue ""
    run.log("Uploading #{name} (#{human_size})...\n")
    File.open(path, "r") do |f|
      Swift.client.put_object name, f, Swift.container, {"Content-Type" => 'application/gzip'}
      artifact_url(name) 
    end
  end

  def freeze_attr(automation)
    serializer = AutomationSnapshotSerializer.new(automation, {})
    serializer.attributes.delete_if { |k, v| v.blank? }
  end

end
