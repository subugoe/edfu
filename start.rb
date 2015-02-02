#!/usr/bin/env ruby

if File.exist?("temp/pids/server.pid")
  `rm tmp/pids/server.pid`
end

puts "\ndocker stop $(docker ps -a -q)"
`docker stop $(docker ps -a -q)`

puts "\nfig build"
`fig  build`

puts "\nfig up -d"
`fig up -d`

puts "\nfig run  web  rake db:drop db:create db:migrate create_default_user"
`fig run  web  rake db:drop db:create db:migrate create_default_user`

#puts "\ndocker ps"
#container = `docker ps`
#container.lines { |container|
#
#  if container.include? "web"
#    container_id = container.split[0]
#    `docker exec #{container_id} rake create_default_user`
#  end
#}