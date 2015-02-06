# encoding: utf-8 

require 'edfu_model_helper'
require 'rsolr'
# require 'celluloid/autostart'

class Ort < ActiveRecord::Base
  extend EdfuModelHelper

  has_many :stellen, as: :zugehoerigZu, :dependent => :delete_all

  def transliteration_nosuffix
    return self.transliteration
  end

  def transliteration_nosuffix= tn
    self.transliteration= tn
  end

  def to_solr_string

    begin
      stelle = self.stellen.first.start
    rescue NoMethodError
      EdfuLog.new("ERROR", "OL-Model", "Fehlerhafter Start in Stelle (solr sort daher '<transliteration>--' statt '<transliteration>--<stelle>')", "STELLE", '', '', self.uid)

      stelle = ''
    end

    return {
        :sql_uid                  => self[:uid],
        :sort                     => "#{self[:transliteration]}--#{stelle}", # ---

        :transliteration          => self[:transliteration], # ---

        :transliteration_nosuffix => self[:transliteration], # ---
        :ort                      => self[:ort], # ---
        :lokalisation             => self[:lokalisation], # ---
        :anmerkung                => self[:anmerkung], # ---

        :stelle_id                => self.stellen.collect { |stelle| "stelle-#{stelle.id}" }, # ---

        :band                     => self.stellen.collect { |stelle| stelle.band }, # ---
        :bandseite                => self.stellen.collect { |stelle| stelle.bandseite }, # ---
        :bandseitezeile           => self.stellen.collect { |stelle| stelle.bandseitezeile }, # ---

        :seite_start              => self.stellen.collect { |stelle| stelle.seite_start }, # ---
        :seite_stop               => self.stellen.collect { |stelle| stelle.seite_stop }, # ---
        :zeile_start              => self.stellen.collect { |stelle| stelle.zeile_start }, # ---
        :zeile_stop               => self.stellen.collect { |stelle| stelle.zeile_stop }, # ---

        :zerstoerung              => self.stellen.collect { |stelle| stelle.zerstoerung }, # ---
        :freigegeben              => self.stellen.collect { |stelle| stelle.freigegeben }, # ---
        :stelle_unsicher          => self.stellen.collect { |stelle| stelle.stelle_unsicher }, # ---
        :stelle_anmerkung         => self.stellen.collect { |stelle| stelle.stelle_anmerkung }, # ---

        :typ                      => 'ort', # ---
        :id                       => "ort-#{self[:uid]}" # ---
    }
  end


  private


  def add_to_solr

    solr = RSolr.connect :url => 'http://localhost:8983/solr/collection1'
    solr.add (to_solr_string)
    solr.commit

  end


end