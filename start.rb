#!/usr/bin/env ruby
#
# use this script if you start the containers for the first time; then use restart.rb

require 'fileutils'


if File.exist?("temp/pids/server.pid")
  `rm tmp/pids/server.pid`
end


env = ENV['DOCKER_ENV'] || 'local'

if (env == "production")
  puts "run production environment"
  file    = "compose_prod.yml"
  service = "web db"
elsif (env == "development")
  puts "run development environment"
  file    = "compose_dev.yml"
  service = "web db"
else
  puts "run local environment"
  file    = "compose_local.yml"
  service = ""
end

puts "\nStop running containers (docker-compose stop)"
`docker-compose -f #{file} stop #{service}`

puts "\nRemove the containers (docker-compose rm ...)"
`docker-compose -f #{file} rm --force #{service}`

puts "\nBuild the containers (docker-compose build ...)"
`docker-compose -f #{file} build   #{service}`

puts "\nStart the containers (docker-compose up -d)"
`docker-compose -f #{file} up -d  #{service}`

puts "\nRun database migrations (docker-compose run  web  rake ... "
`docker-compose -f #{file} run  web  rake db:drop db:create db:migrate create_default_user`



