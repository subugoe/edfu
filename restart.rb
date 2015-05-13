#!/usr/bin/env ruby


puts "\ndocker-compose stop web"
`docker-compose stop web`

if File.exist?("temp/pids/server.pid")
  `rm tmp/pids/server.pid`
end

puts "\ndocker-compose build"
`docker-compose build`

puts "\ndocker-compose start web"
`docker-compose start web`

puts "\ndocker-compose run  web  rake db:drop db:create db:migrate create_default_user RAILS_ENV='production'"
`docker-compose run  web  rake db:drop db:create db:migrate create_default_user  RAILS_ENV='production' `