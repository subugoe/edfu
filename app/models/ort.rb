# encoding: utf-8 

require 'edfu_model_helper'
require 'rsolr'
# require 'celluloid/autostart'

class Ort < ActiveRecord::Base
  extend EdfuModelHelper

  has_many :stellen, as: :zugehoerigZu, :dependent => :delete_all

  attr_accessor :szenen

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
      Edfulog.new("ERROR", "OL-Model", "Fehlerhafter Start in Stelle (solr sort daher '<transliteration>--' statt '<transliteration>--<stelle>')", "STELLE", '', '', self.uid)

      stelle = ''
    end

    anmerkungen = self.stellen.collect { |stelle|
      if stelle.stelle_anmerkung = ''
        ' '
      else
        stelle.stelle_anmerkung
      end
    }

    h = {
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
        :id                       => "ort-#{self[:uid]}", # ---
    }

    # --- szene

    if self.szenen !=nil && self.szenen.size > 0

      h.merge!({
                   :szene_hoehe          => self.szenen.collect { |szene| szene.hoehe },
                   :szene_prozent_z      => self.szenen.collect { |szene| szene.prozent_z },
                   :szene_bild_hoehe     => self.szenen.collect { |szene| szene.bild_hoehe },
                   :szene_bild_polygon   => self.szenen.collect { |szene| szene.polygon },
                   :szene_bild_rect      => self.szenen.collect { |szene| szene.rect },
                   :szene_bild_name      => self.szenen.collect { |szene| szene.name },
                   :szene_grau           => self.szenen.collect { |szene| szene.grau },
                   :szene_blickwinkel    => self.szenen.collect { |szene| szene.blickwinkel },
                   :szene_uid            => self.szenen.collect { |szene| szene.id },
                   :szene_bild_offset_y  => self.szenen.collect { |szene| szene.offset_y },
                   :szene_bild_offset_x  => self.szenen.collect { |szene| szene.offset_x },
                   :szene_nummer         => self.szenen.collect { |szene| szene.nummer },
                   :szene_beschreibung   => self.szenen.collect { |szene| szene.beschreibung },
                   :szene_bild_dateiname => self.szenen.collect { |szene| szene.dateiname },
                   :szene_bild_breite    => self.szenen.collect { |szene| szene.bild_breite },
                   :szene_koordinate_y   => self.szenen.collect { |szene| szene.koordinate_y },
                   :szene_koordinate_x   => self.szenen.collect { |szene| szene.koordinate_x },
                   :szene_breite         => self.szenen.collect { |szene| szene.breite }
               })

    end

    return h

  end


  private


  # def add_to_solr
  #
  #   solr = RSolr.connect :url => 'http://localhost:8983/solr/collection1'
  #   solr.add (to_solr_string)
  #   solr.commit
  #
  # end


end