### Build and run the Project

* (1)set required environment variables
    * depending on the value of the DOCKER_ENV different services will be started
        * for the local env a solr container will be started
        * the dev and prod hosts use remote solr instances
    * for Rails, possible values { development | production }
        * export RAILS_ENV=
    * for Docker, possible values { local | development | production }
        * export DOCKER_ENV=
        * local uses a container based Solr, development and production are using an external Solr
* (2) after deployment and before start set required secret tokens and database passwords to permit access
    * copy the file config/edfu_config.yml.template to config/edfu_config.yml
        * add a username/password pair per user
    * copy the file config/secrets.yml.template to config/secrets.yml
        * add a token for the production environment
* with docker
    * Install the Docker environment: docker, docker-compose, for Mac VirtualBox and Boot2docker
    * start the environment
	    * with boot2docker (Windows, Moc OS)
		    * boot2docker init
    		* boot2docker start
	    	* $(boot2docker shellinit)
	    * set the environment variables - steps (1) and (2)
	    * start the services (from project path)
		    * ruby start.rb
        	    * it builds the application, creates the database and starts the server and application
    * to look inside an container (connect to a running container)
        * docker exec -it [container-id] /bin/bash
            * you can find out the id with "docker ps"
    * Get the IP-Address, for Mac and Windows it is not localhost
	    * boot2docker ip
* without Docker (for local tests)
    * customise the 'host' parameter for the default environment in config/database.yml
        * host: localhost
    * set the environment variables - steps (1) and (2)
    * set an environment variable for the Solr endpoint
        * $> export SOLR_ENDPOINT=http://...
    * start the local Postgres Server
    * start the local Solr Server
    * for the PRODUCTION environment precompile the assets (from project path)
        * $> RAILS_ENV=production rake assets:clean assets:precompile
    * Build the database and start the server (from project path)
        * $> rake db:drop db:create db:migrate create_default_user
        * $> bundle exec passenger start
* Request the site
	    * http://...ip...:3000
* Jenkins
    * Jenkins sets also the environment variables RAILS_ENV and DOCKER_ENV
