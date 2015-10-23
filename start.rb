#!/usr/bin/env ruby
#
# use this script if you start the containers for the first time; then use restart.rb

require 'fileutils'
require 'socket'

adr = IPSocket.getaddress(Socket.gethostname)


if File.exist?("temp/pids/server.pid")
  `rm tmp/pids/server.pid`
end


if (adr == "134.76.19.143" || adr == "141.5.103.93")

  puts "\nStop running containers (docker-compose stop)"
  `docker-compose stop web db`

  puts "\nRemove the containers (docker-compose rm ...)"
  `docker-compose rm --force web db`

  puts "\nBuild the containers (docker-compose build ...)"
  `docker-compose build  --no-cache web db`

  puts "\nStart the containers (docker-compose up -d)"
  `docker-compose up -d web db`


else

  puts "\nStop running containers (docker-compose stop)"
  `docker-compose stop`

  puts "\nRemove the containers (docker-compose rm ...)"
  `docker-compose rm --force`

  puts "\nBuild the containers (docker-compose build ...)"
  `docker-compose build  --no-cache`

  puts "\nStart the containers (docker-compose up -d)"
  `docker-compose up -d`

end


puts "\nRun database migrations (docker-compose run  web  rake ...'"
if (adr == "134.76.19.143")
  puts "prod"
  `docker-compose run  web  rake db:drop db:create db:migrate create_default_user RAILS_ENV='production'`
else
  puts "dev"
  `docker-compose run  web  rake db:drop db:create db:migrate create_default_user RAILS_ENV='development'`
end


