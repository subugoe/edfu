# encoding: utf-8 

require 'edfu_model_helper'
require 'rsolr'
#require 'celluloid/autostart'

class Wort < ActiveRecord::Base
  extend EdfuModelHelper

  has_one :wbberlin
  has_many :stellen, as: :zugehoerigZu, :dependent => :delete_all

  #belongs_to :wbberlin


  #after_commit :add_to_solr
  #before_validation :check_data

  def to_solr_string

    begin
      stelle = self.stellen.first.start
    rescue NoMethodError
      puts "problem mit solr-sort: für uid: #{self.uid} (wort)"
      stelle = ''
    end

    return {
        :sql_uid => self[:uid],

        :transliteration => self[:transliteration],
        :transliteration_nosuffix => self[:transliteration_nosuffix], # ---
        :uebersetzung => self[:uebersetzung], # ---
        :hieroglyph => self[:hieroglyph], # ---
        :weiteres => self[:weiteres], # ---
        :anmerkung => self[:anmerkung], # --- aus self, kein Array

        :stelle_id => self.stellen.collect { |stelle| "stelle-#{stelle.id}" }, # ---
        :band => self.stellen.collect { |stelle| stelle.band }, #
        :bandseite => self.stellen.collect { |stelle| stelle.bandseite }, # ---
        :bandseitezeile => self.stellen.collect { |stelle| stelle.bandseitezeile }, # ---
        :seite_start => self.stellen.collect { |stelle| stelle.seite_start }, # ---
        :seite_stop => self.stellen.collect { |stelle| stelle.seite_stop }, # ---
        :zeile_start => self.stellen.collect { |stelle| stelle.zeile_start }, # ---
        :zeile_stop => self.stellen.collect { |stelle| stelle.zeile_stop }, # ---
        :zerstoerung => self.stellen.collect { |stelle| stelle.zerstoerung }, # ---
        :freigegeben => self.stellen.collect { |stelle| stelle.freigegeben }, # ---
        :stelle_unsicher => self.stellen.collect { |stelle| stelle.stelle_unsicher }, #

        :sort => "Ddt--#{stelle}", # ---  todo
        :berlin_display => self.wbberlin.berlin_display, # ---
        :berlin_band => self.wbberlin.band.to_i, # ---
        :berlin_seite_start => self.wbberlin.seite_start.to_i, # ---
        :berlin_seite_stop => self.wbberlin.seite_stop.to_i, # ---
        :berlin_zeile_start => self.wbberlin.zeile_start.to_i, # ---
        :berlin_zeile_stop => self.wbberlin.zeile_stop.to_i, # ---
        :stelle_berlin_id => self.wbberlin.id,

        :typ => 'wort',
        :id => "wort-#{self[:uid]}"
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
