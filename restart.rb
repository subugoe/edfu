#!/usr/bin/env ruby

Dir.chdir("/home/jenkins/edfu/")


puts "\nstop web container"
container = `docker ps`
container.lines { |container|

  if container.include? "web"
    container_id = container.split[0]
    `docker stop #{container_id}`
  end
}

if File.exist?("temp/pids/server.pid")
  `rm tmp/pids/server.pid`
end

puts "\nfig build"
`fig build`

puts "\nfig restart -d"
`fig restart -d`

puts "\nfig run  web  rake db:drop db:create db:migrate create_default_user"
`fig run  web  rake db:drop db:create db:migrate create_default_user`

