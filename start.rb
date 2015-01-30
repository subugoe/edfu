#!/usr/bin/env ruby

`cd .`
`fig build`
`fig up -d`
`fig run web rake db:drop db:create db:migrate`

container = `Docker ps`
container.lines { |container|

  if container.include? "web"
    container_id = container.split[0]
    `docker exec -it #{container_id} rake create_default_user`
  end
}