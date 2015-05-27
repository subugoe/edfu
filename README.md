### Build and run the Project

* with docker
    * Install docker, fig, (boot2docker)
    * start the environment
	    * with boot2docker (Windows, Moc OS)
		    * boot2docker init
    		* boot2docker start
	    	* $(boot2docker shellinit)
	    * customise the 'host' parameter to 'localhost' (in config/database.yml)
	    * start for the first time
		    * ruby start.rb
        	    * it builds the application, creates the database and starts the application
    * connect to a running container
        * docker exec -it [container-id] /bin/bash
            * you can find out the id with "docker ps"
    * Get the IP-Address
	    * boot2docker ip
* without Docker (for local tests)
    * customise the 'host' parameter to 'localhost' (in config/database.yml)
    * $ cd <to_project_root>
    * start the local Postgres Server
    * start the local Solr Server
    * $ rake db:drop db:create db:migrate create_default_user RAILS_ENV='development'
    * $ bundle exec puma  -t 5:5 -p 3000 -e development  --preload
* Request the site
	    * http://...ip...:3000