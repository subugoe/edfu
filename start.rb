#!/usr/bin/env ruby
#
# use this script if you start the containers for the first time; then use restart.rb

require 'yaml'
require 'fileutils'


if File.exist?("tmp/pids/server.pid")
  `rm tmp/pids/server.pid`
end

if (ENV['DOCKER_ENV'] == "" || ENV['DOCKER_ENV'] == nil)
  puts "Execution aborted! DOCKER_ENV environment variable required: export DOCKER_ENV={ development | production | local}"
  System.exit 1
end

env     = ENV['DOCKER_ENV']
file    = ""
service = ""

if (env == "production")
  puts "run production environment"
  file    = "compose_prod.yml"
  service = "web db"

elsif (env == "development")
  puts "run development environment"
  file    = "compose_dev.yml"
  service = "web db"

elsif (env == "local")
  puts "run local environment"
  file    = "compose_local.yml"
  service = ""

else
  puts "Execution Aborded, DOCKER_ENV environment variable is not set to { development | production | local}.\nSet the environment variable DOCKER_ENV\n  export DOCKER_ENV={ development | production | local} \n  ruby start.rb"
  System.exit 1
end


puts "\nStop running containers (docker-compose stop)"
`docker-compose -f #{file} stop #{service}`

puts "\nRemove the containers (docker-compose rm ...)"
`docker-compose -f #{file} rm --force #{service}`

puts "\nBuild the containers (docker-compose build ...)"
`docker-compose -f #{file} build   #{service}`

if (ENV['RAILS_ENV'] == 'production')

  puts "\nGenerate Secret Key"
  initialized = false
  str         = `docker-compose -f compose_prod.yml  run  web  rake secret`

  key=""

  str.each_line do |line|
    if (!line.strip.empty? && !line.strip.include?(" "))
      key         = line.strip
      initialized = true
    end
  end

  if (!initialized)
    key="fd5d687ce80d9aa20729071487049e0989f861aa596a1b11cd864fd9b76e8ae6f3dccf904e1713bc40ac52045f4be82a7d0df4d27c3e53c27e3520494991c0f9"
  end

  config_file                             = './config/secrets.yml'
  config                                  = YAML::load_file("#{config_file}.template")
  config['production']['secret_key_base'] = key
  File.open(config_file, 'w') { |f| f.write config.to_yaml }

end


if (ENV['RAILS_ENV'] == 'production')
  puts "\nPrecompile assets"
  `docker-compose -f #{file}  run  web  rake assets:precompile`
  puts "\nStart the containers (docker-compose up -d)"
  `docker-compose -f #{file} up -d  #{service}`
else
  puts "\nStart the containers (docker-compose up -d)"
  `docker-compose -f #{file} up -d  #{service}`
end


env_var  = ""
env_vars = `docker-compose -f #{file} run web env`
env_vars.each_line do |line|
  if (line.strip.include?("DB_PORT_5432_TCP_ADDR"))
    e = line.strip
    env_var = e.split('=', 2)[1]
    break
  end
end


if (!(env_var == ""))
  puts "\nask if database is alive"
  `docker-compose -f #{file} run web bash check.sh #{env_var}`
else
  puts "sleep..."
  sleep(90)
end

puts "\nRun database migrations (docker-compose run  web  rake ... "
`docker-compose -f #{file} run  web  rake db:create`
`docker-compose -f #{file} run  web  rake db:migrate`
`docker-compose -f #{file} run  web  rake edfu:create_default_user`



