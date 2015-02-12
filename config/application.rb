require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Edfu
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    # config.action_controller.perform_caching = true
    config.cache_store = :file_store, "tmp/cache/"
    #config.cache_store = :memory_store, {size: 64.megabytes}

    # todo: cron job to remove old logs
    config.logger                 = Logger.new('log/edfu.log', 'daily')
    config.logger.datetime_format = '%Y-%m-%d %H:%M:%S'
    config.logger.formatter       = proc { |severity, datetime, progname, msg|
      # original_formatter.call(severity, datetime, progname, msg.dump)
      "[#{datetime}] #{Edfulog.separator} [#{severity}] #{Edfulog.separator} #{msg}"
    }

  end
end
