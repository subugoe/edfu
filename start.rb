#!/usr/bin/env ruby
#
# use this script if you start the containers for the first time; then use restart.rb

require 'fileutils'


if File.exist?("temp/pids/server.pid")
  `rm tmp/pids/server.pid`
end

puts "\ndocker-compose build"
`docker-compose build`

puts "\ndocker-compose up -d"
`docker-compose up -d`


puts "\ndocker-compose run  web  rake db:drop db:create db:migrate create_default_user  RAILS_ENV='development'"
`docker-compose run  web  rake db:drop db:create db:migrate create_default_user RAILS_ENV='development' `
