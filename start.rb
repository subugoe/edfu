#!/usr/bin/env ruby

#`cd .`
`fig -f /home/jenkins/edfu/fig.yml build`
`fig -d -f /home/jenkins/edfu/fig.yml up`
`fig -f /home/jenkins/edfu/fig.yml run web  rake db:drop db:create db:migrate`

container = `Docker ps`
container.lines { |container|

  if container.include? "web"
    container_id = container.split[0]
    `docker exec -it #{container_id} rake create_default_user`
  end
}
