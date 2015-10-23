class EdfuSolrInterface
  include Celluloid


  if (ENV['DOCKER_ENV'] == "production" || ENV['DOCKER_ENV'] == "development")
    config        = YAML.load_file(Rails.root.join('config', 'edfu_config.yml'))[Rails.env]
    solr_endpoint = config['solr_endpoint']
  else
    solr_domain   = ENV['EDFU_SOLR_1_PORT_8983_TCP_ADDR'] || "127.0.0.1"
    solr_port     = ENV['SOLR_PORT_8983_TCP_PORT'] || "8983"
    solr_endpoint = "http://#{solr_domain}:#{solr_port}/solr/collection1"
  end

  SOLR_CONNECTION = RSolr.connect :url => solr_endpoint
  puts "solr endpoint: #{solr_endpoint}"


  def self.cleanupSolr

    SOLR_CONNECTION.update :data => '<delete><query>*:*</query></delete>'
    SOLR_CONNECTION.update :data => '<commit/>'

  end

  def add_to_solr(solr_string_array)

    if (solr_string_array != nil && solr_string_array.size > 0)
      SOLR_CONNECTION.add (solr_string_array)
      SOLR_CONNECTION.commit
      solr_string_array.clear
    end

  end

end