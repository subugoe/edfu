#!/usr/bin/env ruby
#
# use this script if you start the containers for the first time; then use restart.rb


Dir.chdir(File.expand_path(File.dirname(File.dirname(__FILE__))))


if File.exist?("temp/pids/server.pid")
  `rm tmp/pids/server.pid`
end

puts "\nfig build"
`fig build`

puts "\nfig up -d"
`fig up -d`

puts "\nfig run  web  rake db:drop db:create db:migrate create_default_user"
`fig run  web  rake db:drop db:create db:migrate create_default_user`


