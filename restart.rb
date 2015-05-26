#!/usr/bin/env ruby


puts "\ndocker-compose stop web"
`docker-compose stop web`

if File.exist?("temp/pids/server.pid")
  `rm tmp/pids/server.pid`
end

puts "\ndocker-compose build web"
`docker-compose build web`

puts "\ndocker-compose start web"
`docker-compose up`
