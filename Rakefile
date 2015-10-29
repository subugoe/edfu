# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
#require 'warbler'

Rails.application.load_tasks
#Warbler::Task.new

desc "create a default user"
task :create_default_user do
  config = YAML.load_file(Rails.root.join('config', 'edfu_config.yml'))[Rails.env]
  config['users'].each do |user|

    User.create(
        email: user['user_name'],
        password: user['user_password'],
        password_confirmation: user['user_password'])

  end
  path = "#{File.dirname(__FILE__)}/data/upload"
  FileUtils.rm_rf("#{path}")
end