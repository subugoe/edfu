#!/usr/bin/env ruby
#
# use this script if you start the containers for the first time; then use restart.rb

require 'fileutils'


#Dir.chdir("/var/local/docker/edfu/")
#Dir.chdir("/home/jenkins/edfu")

#FileUtils.mkdir_p("/opt/edfu/data")
#Dir.chdir(File.expand_path(File.dirname(File.dirname(__FILE__))))

puts Dir.getwd

if File.exist?("temp/pids/server.pid")
  `rm tmp/pids/server.pid`
end

puts "\ndocker-compose build"
`docker-compose build`

puts "\ndocker-compose up -d"
`docker-compose up -d`


puts "\ndocker-compose run  web  rake db:drop db:create db:migrate create_default_user  RAILS_ENV='production'"
`docker-compose run  web  rake db:drop db:create db:migrate create_default_user RAILS_ENV='production' `
