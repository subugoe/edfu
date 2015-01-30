#!/usr/bin/env ruby

#`cd .`
`fig build -f /home/jenkins/edfu/fig.yml`
`fig up -d -f /home/jenkins/edfu/fig.yml`
`fig run web  rake db:drop db:create db:migrate  -f /home/jenkins/edfu/fig.yml`

container = `Docker ps`
container.lines { |container|

  if container.include? "web"
    container_id = container.split[0]
    `docker exec -it #{container_id} rake create_default_user`
  end
}
