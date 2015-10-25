class EdfuSolrInterface
  include Celluloid

  def initialize
    if (ENV['DOCKER_ENV'] == "production" || ENV['DOCKER_ENV'] == "development")
      puts "on remote host"
      config        = YAML.load_file(Rails.root.join('config', 'edfu_config.yml'))[Rails.env]
      @solr_endpoint = config['solr_endpoint']
    else
      puts "on local host"
      solr_domain   = ENV['EDFU_SOLR_1_PORT_8983_TCP_ADDR'] || "127.0.0.1"
      solr_port     = ENV['SOLR_PORT_8983_TCP_PORT'] || "8983"
      @solr_endpoint = "http://#{solr_domain}:#{solr_port}/solr/collection1"
    end

    @solr_connection = RSolr.connect :url => @solr_endpoint
    puts "solr endpoint: #{@solr_endpoint}"
  end

  def cleanupSolr

    @solr_connection.update :data => '<delete><query>*:*</query></delete>'
    @solr_connection.update :data => '<commit/>'

  end

  def add_to_solr(solr_string_array)

    if (solr_string_array != nil && solr_string_array.size > 0)
      @solr_connection.add (solr_string_array)
      @solr_connection.commit
      solr_string_array.clear
    end

  end

end