# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Precompile additional assets.
# application.js, application.css.scss, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
Rails.application.config.assets.precompile +=  %w( edfu_status.js edfu_status.css edfulogs.js edfulogs.css errors.js errors.css formulare.js formulare.css  goetter.js goetter.css orte.js orte.css stellen.js stellen.css uploads.js uploads.css wbsberlin.js wbsberlin.css worte.js worte.css court.js noise.png logo.png )