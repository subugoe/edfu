require 'bcrypt'
require 'app/models/user'

module Edfu
  class Application < Rails::Application

    config.before_initialize do
      # initialization code goes here

      User.find_or_create_by(email: 'admin@edfu.de') do

      password = 'adminadmin'
      password_confirmation = 'adminadmin'

      end
    end

  end
end



