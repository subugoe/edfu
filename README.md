### Build and run the Project

* Install docker, fig, (boot2docker)
* start the environment
	* with boot2docker 
		* boot2docker init
		* boot2docker start
		* $(boot2docker shellinit) 
	* fig build
	* fig run edfuweb rake db:drop db:create db:migrate create_default_user	* fig up
	    * please find the container names in th e fig.yml config file (here: edfuweb)
	* fig up
* connect to a running container
    * docker exec -it [container-id] /bin/bash
        * you can find out the id with "docker ps"
* Get the IP-Address
	* boot2docker ip
* Request the site
	* http://...ip...:3000