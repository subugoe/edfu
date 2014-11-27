# encoding: utf-8 

require 'lib/edfu_model_helper'

class Stelle < ActiveRecord::Base
  extend EdfuModelHelper

  belongs_to :zugehoerigZu, polymorphic: true


  after_update :log_updated
  after_create :log_created

  searchable do

    integer :uid, stored: true
    text :tempel, stored: true
    integer :band, stored: true
    integer :seite_start, stored: true
    integer :seite_stop, stored: true
    integer :zeile_start, stored: true
    integer :zeile_stop, stored: true
    text :stelle_anmerkung, stored: true
    boolean :stelle_unsicher, stored: true
    integer :start, stored: true
    integer :stop, stored: true
    boolean :zerstoerung, stored: true
    boolean :freigegeben, stored: true
    # t.references :zugehoerigZu, polymorphic: true
    # todo besitzer hinzufügen, id hinzufügen, typ hinzufügen


  end


  private



  # todo update solr doc
  # todo log updated
  def log_updated
    logger.info "[INFO]  after update: #{id}"
  end


  # todo add doc to solr
  # todo log created
  def log_created

    logger.info "[INFO]  before save: #{id}"

  end



end

