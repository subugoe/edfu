#!/usr/bin/env ruby

#`cd .`
`sudo fig -f /home/jenkins/edfu/fig.yml build`
`sudo fig -d -f /home/jenkins/edfu/fig.yml up`
`sudo fig -f /home/jenkins/edfu/fig.yml run web  rake db:drop db:create db:migrate`

container = `sudo Docker ps`
container.lines { |container|

  if container.include? "web"
    container_id = container.split[0]
    `docker exec -it #{container_id} rake create_default_user`
  end
}
