# encoding: utf-8 

require 'rsolr'
require 'edfu_model_helper'
require 'edfu_numerics_conversion_helper'
require 'celluloid/autostart'

class Stelle < ActiveRecord::Base
  extend EdfuModelHelper


  belongs_to :zugehoerigZu, polymorphic: true
  has_and_belongs_to_many :szenen, :dependent => :delete_all

  #after_commit :add_to_solr


  def start
    return "#{self[:band]}#{'%03i' % self[:seite_start]}#{'%03i' % self[:zeile_start]}"
  end

  def stop
    return "#{self[:band]}#{'%03i' % self[:seite_stop]}#{'%03i' % self[:zeile_stop]}"
  end

  def to_solr_string
    return {
        :sql_uid => self[:id], # ---

        :tempel => self.tempel, # ---
        :band => self.band, # ---

        :seite_start => self.seite_start, # ---
        :seite_stop => self.seite_stop, # ---
        :zeile_start => self.zeile_start, # ---
        :zeile_stop => self.zeile_stop, # ---
        :start => self.start, # ---
        :stop => self.stop, # ---

        :freigegeben => self.freigegeben, # ---
        :zerstoerung => self.zerstoerung, # ---
        # todo: check if to_s meet the requirements
        :stelle_anmerkung => self.stelle_anmerkung.to_s, # ---
        :stelle_unsicher => self.stelle_unsicher, # ---

        # todo: uncomment this
        # :besitzer => "#{self.zugehoerigZu_type.downcase}-#{self.zugehoerigZu.uid}", # ---

        :typ => 'stelle', # ---
        :id => "stelle-#{self[:id]}" # ---
    }
  end


  private


  def add_to_solr

    # todo extract
    solr = RSolr.connect :url => 'http://localhost:8983/solr/collection1'
    solr.add (to_solr_string)
    solr.commit
  end

end

