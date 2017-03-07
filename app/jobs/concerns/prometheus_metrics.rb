require 'active_support/concern'
module PrometheusMetrics 
  extend ActiveSupport::Concern

  included do
    registry = Prometheus::Client.registry
    unless registry.exist? :active_job_duration_seconds
      @@job_durations = registry.histogram(:active_job_duration_seconds, "A histogram of the job duration", {}, [5,10,30,60,120,300,600,1800,3600,7200])
    end
    unless registry.exist? :active_job_exceptions_total
      @@job_exceptions = registry.counter(:active_job_exceptions_total, "A counter of the total number of exceptions raised")
    end

    around_perform do |job, block|
      trace { block.call }
    end
  end

  private

  def trace
    start = Time.now
    yield
    duration = [(Time.now - start).to_f, 0.0].max
    record(duration)
  rescue => exception
    @@job_exceptions.increment(exception: exception.class.name, job_class: self.class.name )
    raise
  end

  def record(duration)
    @@job_durations.observe({job_class: self.class.name}, duration)
  end

end
