# encoding: utf-8 

require 'lib/edfu_model_helper'

class Stelle < ActiveRecord::Base
  extend EdfuModelHelper

  belongs_to :zugehoerigZu, polymorphic: true


  #after_update :log_updated
  #after_create :log_created
  after_commit :add_to_solr

  # searchable do
  #
  #   # integer :uid, stored: true
  #   text :tempel, stored: true
  #   integer :band, stored: true
  #   integer :bandseite, stored: true
  #   integer :bandseitezeile, stored: true
  #   integer :seite_start, stored: true
  #   integer :seite_stop, stored: true
  #   integer :zeile_start, stored: true
  #   integer :zeile_stop, stored: true
  #   text :stelle_anmerkung, stored: true
  #   boolean :stelle_unsicher, stored: true
  #   integer :start, stored: true
  #   integer :stop, stored: true
  #   boolean :zerstoerung, stored: true
  #   boolean :freigegeben, stored: true
  #   # t.references :zugehoerigZu, polymorphic: true
  #   # todo besitzer hinzufügen, id hinzufügen, typ hinzufügen
  #
  #
  # end

  def start
    return "#{self[:band]}#{'%03i' % self[:seite_start]}#{'%03i' % self[:zeile_start]}"
  end

  def stop
    return "#{self[:band]}#{'%03i' % self[:seite_stop]}#{'%03i' % self[:zeile_stop]}"
  end

  private

  def add_to_solr

    # todo extract
    solr = RSolr.connect :url => 'http://localhost:8983/solr/collection1'

    #   # integer :uid, stored: true
    #   text :tempel, stored: true
    #   integer :band, stored: true
    #   integer :bandseite, stored: true
    #   integer :bandseitezeile, stored: true
    #   integer :seite_start, stored: true
    #   integer :seite_stop, stored: true
    #   integer :zeile_start, stored: true
    #   integer :zeile_stop, stored: true
    #   text :stelle_anmerkung, stored: true
    #   boolean :stelle_unsicher, stored: true
    #   integer :start, stored: true
    #   integer :stop, stored: true
    #   boolean :zerstoerung, stored: true
    #   boolean :freigegeben, stored: true
    #   # t.references :zugehoerigZu, polymorphic: true
    #   # todo besitzer hinzufügen, id hinzufügen, typ hinzufügen

    solr.add (
                 {
                     :sql_uid => self[:id], # ---

                     :tempel => self.tempel, # ---
                     :band => self.band, # ---

                     :seite_start => self.seite_start, # ---
                     :seite_stop => self.seite_stop, # ---
                     :zeile_start => self.zeile_start, # ---
                     :zeile_stop => self.zeile_stop, # ---
                     :start => start, # ---
                     :stop => stop, # ---

                     :freigegeben => self.freigegeben, # ---
                     :zerstoerung => self.zerstoerung, # ---
                     :stelle_anmerkung => self.stelle_anmerkung, # ---
                     :stelle_unsicher => self.stelle_unsicher, # ---

                     :besitzer => "#{self.zugehoerigZu_type.downcase}-#{self.zugehoerigZu.uid}", # ---

                     :typ => 'stelle', # ---
                     :id => "stelle-#{self[:id]}" # ---
                 }
             )

    solr.commit


  end




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

