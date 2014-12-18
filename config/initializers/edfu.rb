module Edfu
  class Application < Rails::Application

    config.before_initialize do
      config = YAML.load_file(Rails.root.join('config', 'edfu_config.yml'))[Rails.env]
      config['users'].each do |user|
        u = User.create(email: user['user_name'], password: user['user_password'], password_confirmation: user['user_password'])
        #puts u.errors.full_messages
      end
    end

  end
end



