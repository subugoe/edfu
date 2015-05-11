class FormularSolrWorker
  include Sidekiq::Worker

  SOLR_DOMAIN = ENV['EDFU_SOLR_1_PORT_8983_TCP_ADDR']
  SOLR_PORT   = ENV['SOLR_PORT_8983_TCP_PORT']
  #SOLR_DOMAIN = "127.0.0.1"
  #SOLR_PORT   = "8983"


  SOLR_CONN   = RSolr.connect :url => "http://#{SOLR_DOMAIN}:#{SOLR_PORT}/solr/collection1"
  #SOLR_CONN = RSolr.connect :url => "http://localhost:8983/solr/collection1"

  def perform(ids)
    ids.each do |id|
      f = Formular.find(id)
      SOLR_CONN.add (f.to_solr_string)
      SOLR_CONN.commit
    end
  end

end