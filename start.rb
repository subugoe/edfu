#!/usr/bin/env ruby

#`cd .`
puts 'fig build'
`sudo fig -d -f /home/jenkins/edfu/fig.yml build`

puts 'fig up -d'
`sudo fig -d -f /home/jenkins/edfu/fig.yml up`

puts 'fig run web ...'
`sudo fig -d -f /home/jenkins/edfu/fig.yml run web  rake db:drop db:create db:migrate`

puts 'docker ps ...'
container = `sudo docker ps`
container.lines { |container|

  if container.include? "web"
    container_id = container.split[0]
    `docker exec -d #{container_id} rake create_default_user`
  end
}
