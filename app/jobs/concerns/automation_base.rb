require 'swift'
require 'arc-client'
module AutomationBase
  extend ActiveSupport::Concern

  included do
    attr_reader :run

    rescue_from(StandardError) do |exception|
      bt = Rails.backtrace_cleaner.clean(exception.backtrace)
      msg = "<#{exception.class}> #{exception}:\n" + bt.join("\n")
      log_error(msg)
    end

    rescue_from(Arc::AgentsNotFoundException) do |exception|
      msg = exception.to_s
      log_error(msg)
    end

    rescue_from(ArcClient::ApiError) do |exception|
      msg = "<#{exception.class}> #{exception}"
      log_error(msg)
    end

    before_perform do |job|
      logger.info "Running #{self.class} for automation(id=#{begin
                                                                    job.arguments[2].id
                                                             rescue StandardError
                                                               'unknown'
                                                                  end})"
      @run = Run.find_by_job_id!(job.job_id)
    end
  end

  def execute(command)
    out = `#{command} 2>&1`
    raise "Executing [#{command}] failed (#{$CHILD_STATUS.exitstatus}):\n#{out}" if $CHILD_STATUS.exitstatus != 0

    out
  end

  def artifact_name(sha)
    "#{sha}-#{self.class.to_s.downcase.gsub(/automation|job/, '')}.tgz"
  end

  def artifact_published?(name)
    Swift.client.head_object(name, Swift.container)
    true
  rescue SwiftClient::ResponseError
    false
  end

  def artifact_url(name)
    Swift.client.temp_url name, Swift.container, {}
  end

  def publish_artifact(path, name)
    human_size = begin
                   ActiveSupport::NumberHelper::NumberToHumanSizeConverter.new(File.size?(path), {}).convert
                 rescue StandardError
                   ''
                 end
    run.log("Uploading #{name} (#{human_size})...\n")
    File.open(path, 'r') do |f|
      # prepare headers
      headers = { 'Content-Type' => 'application/gzip' }
      # check for expiration date
      expiration_date_months = ENV['MONSOON_SWIFT_OBJECT_EXPIRATION_DATE_MONTHS'].to_i
      if expiration_date_months > 0
        expiration_date = Time.now.advance(months: expiration_date_months).to_i.to_s
        headers['X-Delete-At'] = expiration_date
      end
      # put object into swift
      Swift.client.put_object name, f, Swift.container, headers, {}
      artifact_url(name)
    end
  end

  def freeze_attr(automation)
    serializer = AutomationSnapshotSerializer.new(automation, {})
    serializer.attributes.delete_if { |_k, v| v.blank? }
  end

  private

  def log_error(msg)
    logger.error msg
    run.log msg
    run.update!(state: 'failed')
  end
end
