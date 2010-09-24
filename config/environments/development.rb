# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = false
config.action_view.debug_rjs                         = true

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false

if File.exist?(hosts_file = File.join('config','hosts.yml'))
  hosts = YAML.load_file(hosts_file)
  APPLICATION_HOST_NAME = hosts['host_name']
  APPLICATION_C3_DOMAIN = hosts['c3_domain']
  APPLICATION_STANDARD_DOMAIN = hosts['standard_domain']
  ActionController::Base.session_options[:session_domain] = hosts['session_domain']
else
  APPLICATION_HOST_NAME = 'theballot.staging.radicaldesigns.org'
  APPLICATION_C3_DOMAIN = 'nonpartisan.theballot.staging.radicaldesigns.org'
  APPLICATION_STANDARD_DOMAIN = 'theballot.staging.radicaldesigns.org'
  ActionController::Base.session_options[:session_domain] = '.theballot.staging.radicaldesigns.org'
end

config.action_mailer.delivery_method = :sendmail
ActionController::Base.session_options[:session_key] = 'theballot_session_id'
