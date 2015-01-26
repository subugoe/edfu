# encoding: utf-8 

require 'edfu_model_helper'
require 'edfu_numerics_conversion_helper'
require 'rsolr'
#require 'celluloid/autostart'

class Gott < ActiveRecord::Base
  include EdfuNumericsConversionHelper
  extend EdfuModelHelper

  # todo has_many or has_one?
  has_many :stellen, as: :zugehoerigZu, :dependent => :delete_all

  attr_accessor :transliteration_nosuffix

  #after_commit :add_to_solr
  #before_validation :check_data


  def to_solr_string
    begin
      stelle = self.stellen.first.start
    rescue NoMethodError
      logger.error "[ERROR] Problem mit der Stelle in solr sort Feld für uid: #{self.uid}, sort: 'Act--' statt 'Act--<stelle>' (gott)"
      stelle = ''
    end

    return {
        :sql_uid => self[:uid], # ---
        :transliteration => self[:transliteration], # ---
        :transliteration_nosuffix => self[:transliteration], # ? ---
        :ort => self[:ort], # ---
        :eponym => self[:eponym], # ---
        :beziehung => self[:beziehung], # ---
        :funktion => self[:funktion], # ---
        :band => roemisch_nach_dezimal(band.to_s.strip).to_i,

        :anmerkung => self[:anmerkung], # ---
        :sort => "Act--#{stelle}", # --- todo

        :freigegeben => self.stellen.collect { |stelle| stelle.freigegeben }, # ---
        :zerstoerung => self.stellen.collect { |stelle| stelle.zerstoerung }, # ---
        :stelle_unsicher => self.stellen.collect { |stelle| stelle.stelle_unsicher }, # ---
        :stelle_anmerkung => self.stellen.collect { |stelle| stelle.stelle_anmerkung }, # ---
        :seite_start => self.stellen.collect { |stelle| stelle.seite_start }, # ---
        :seite_stop => self.stellen.collect { |stelle| stelle.seite_stop }, # ---
        :zeile_start => self.stellen.collect { |stelle| stelle.zeile_start }, # ---
        :zeile_stop => self.stellen.collect { |stelle| stelle.zeile_stop }, # ---
        :bandseite => self.stellen.collect { |stelle| stelle.bandseite }, # ---
        :bandseitezeile => self.stellen.collect { |stelle| stelle.bandseitezeile }, # ---
        :stelle_id => self.stellen.collect { |stelle| "stelle-#{stelle.id}" }, # ---

        :typ => 'gott', # ---
        :id => "gott-#{self[:uid]}" # ---
    }
  end


  private


  def add_to_solr

    solr = RSolr.connect :url => 'http://localhost:8983/solr/collection1'
    solr.add (to_solr_string)
    solr.commit
  end


end
