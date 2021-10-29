require File.expand_path('boot', __dir__)

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
# require 'active_storage/engine'
require 'action_controller/railtie'
# require "action_mailer/railtie"
# require "action_view/railtie"
# require "sprockets/railtie"
# require "rails/test_unit/railtie"
require 'sprockets/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MonsoonAutomation
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Add metrics to Prometheus
    require 'prometheus/client/rack/collector'
    config.middleware.insert_after ActionDispatch::DebugExceptions, Prometheus::Client::Rack::Collector do |env|
      {
        method: env['REQUEST_METHOD'].downcase,
        # just take the first component of the path as a label
        path: env.fetch('REQUEST_PATH', '')[0, env.fetch('REQUEST_PATH', '').index('/', 1) || 20],
        controller: env.fetch('action_dispatch.request.path_parameters', {}).fetch(:controller, ''),
        action: env.fetch('action_dispatch.request.path_parameters', {}).fetch(:action, '')
      }
    end

    require 'prometheus/client/rack/exporter'
    config.middleware.insert_after Prometheus::Client::Rack::Collector, Prometheus::Client::Rack::Exporter

    # Do not swallow errors in after_commit/after_rollback callbacks.
    # config.active_record.raise_in_transactional_callbacks = true

    # we override this in test.rb to :test
    config.active_job.queue_adapter = :que

    # to properly save Que's schema we store the schema as sql
    config.active_record.schema_format = :sql

    # raise "The next line can be deleted in Rails 5" if Rails::VERSION::MAJOR > 4
    # config.autoload_paths << "#{config.root}/app/jobs/concerns"

    config.action_dispatch.perform_deep_munge = false

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true
  end
end
