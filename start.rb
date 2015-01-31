#!/usr/bin/env ruby

#`cd .`

puts "\ndocker stop $(docker ps -a -q)"
`sudo docker stop $(docker ps -a -q)`

puts "\nfig build"
`sudo fig  build`

puts "\nfig up -d"
`sudo fig up -d`

puts "\nfig run  web  rake db:drop db:create db:migrate create_default_user"
`sudo fig run  web  rake db:drop db:create db:migrate create_default_user`

#puts "\ndocker ps"
#container = `sudo docker ps`
#container.lines { |container|
#
#  if container.include? "web"
#    container_id = container.split[0]
#    `docker exec #{container_id} rake create_default_user`
#  end
#}