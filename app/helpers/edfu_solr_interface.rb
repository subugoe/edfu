class EdfuSolrInterface
  include Celluloid

  SOLR_DOMAIN = ENV['EDFU_SOLR_1_PORT_8983_TCP_ADDR'] || "127.0.0.1"
  SOLR_PORT   = ENV['SOLR_PORT_8983_TCP_PORT'] || "8983"
  #SOLR_DOMAIN = "127.0.0.1"
  #SOLR_PORT   = "8983"

  puts "---->  #{SOLR_DOMAIN}:#{SOLR_PORT}"

  SOLR_CONN   = RSolr.connect :url => "http://#{SOLR_DOMAIN}:#{SOLR_PORT}/solr/collection1"


  def self.cleanupSolr

    SOLR_CONN.update :data => '<delete><query>*:*</query></delete>'
    SOLR_CONN.update :data => '<commit/>'

  end

  def add_to_solr(solr_string_array)

    if (solr_string_array != nil && solr_string_array.size > 0)
      SOLR_CONN.add (solr_string_array)
      SOLR_CONN.commit
      solr_string_array.clear
    end

  end

end