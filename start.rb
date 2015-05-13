#!/usr/bin/env ruby
#
# use this script if you start the containers for the first time; then use restart.rb

require 'fileutils'


if File.exist?("temp/pids/server.pid")
  `rm tmp/pids/server.pid`
end

puts "\nStop running containers (docker-compose stop)"
`docker-compose stop`

puts "\nRemove the containers (docker-compose rm ...)"
`docker-compose rm --force`

puts "\nBuild the containers (docker-compose build ...)"
`docker-compose build  --no-cache`

puts "\nStart the containers (docker-compose up -d)"
`docker-compose up -d`

puts "\nRun database migrations (docker-compose run  web  rake ...'"
`docker-compose run  web  rake db:drop db:create db:migrate create_default_user RAILS_ENV='development' `
