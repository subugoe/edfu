### Build and run the Project

* Install docker, fig, (boot2docker)
* start the environment
	* with boot2docker (Windows, Moc OS)
		* boot2docker init
		* boot2docker start
		* $(boot2docker shellinit) 
	* start for the first time
		* ruby start.rb	 	
	* restart
		* ruby restart.rb 
	* the scripts build the application, creates the database and start the application
* connect to a running container
    * docker exec -it [container-id] /bin/bash
        * you can find out the id with "docker ps"
* Get the IP-Address
	* boot2docker ip
* Request the site
	* http://...ip...:3000