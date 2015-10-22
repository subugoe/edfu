class EdfuSolrInterface
  include Celluloid

  config          = YAML.load_file(Rails.root.join('config', 'edfu_config.yml'))[Rails.env]
  SOLR_CONNECTION = RSolr.connect :url => config['solr_endpoint']


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