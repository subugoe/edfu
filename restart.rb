#!/usr/bin/env ruby

Dir.chdir(File.expand_path(File.dirname(File.dirname(__FILE__))))


#puts "\nstop web container"
#container = `docker ps`
#container.lines { |container|
#
#  if container.include? "web"
#    container_id = container.split[0]
#    `docker stop #{container_id}`
#  end
#}

puts "\nfig stop web"
`fig stop web`

if File.exist?("temp/pids/server.pid")
  `rm tmp/pids/server.pid`
end

puts "\nfig build"
`fig build`

puts "\nfig start web"
`fig start web`

puts "\nfig run  web  rake db:drop db:create db:migrate create_default_user"
`fig run  web  rake db:drop db:create db:migrate create_default_user`