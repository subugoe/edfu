namespace :edfu do

  desc "create a default user"
  task create_default_user: :environment do

    config = YAML.load_file(Rails.root.join('config', 'edfu_config.yml'))[Rails.env]
    config['users'].each do |user|

      User.create(
          email:                 user['user_name'],
          password:              user['user_password'],
          password_confirmation: user['user_password']
      )

    end

    path = "#{File.dirname(__FILE__)}/data/upload"
    FileUtils.rm_rf("#{path}")

  end

end
