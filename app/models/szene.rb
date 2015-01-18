require 'rsolr'

class Szene < ActiveRecord::Base
  extend EdfuModelHelper

  has_and_belongs_to_many :stellen, :dependent => :delete_all
  has_many :szenebilder

  #after_commit :add_to_solr
  #before_validation :check_data

  def to_solr_string
    return {

        # from szenebild
        :szene_bild_name => self.szenebilder[0].name, # --
        :szene_bild_dateiname => self.szenebilder[0].dateiname, # --

        :szene_bild_breite => self.szenebilder[0].breite, #  # --
        :szene_bild_hoehe => self.szenebilder[0].hoehe, #  # --

        :szene_bild_offset_x => self.szenebilder[0].offset_x, # --
        :szene_bild_offset_y => self.szenebilder[0].offset_y, # --

        # from szene

        :typ => 'szene',# --
        :id => "szene-#{self[:id]}", # --
        :szene_uid => self[:id], # --

        :szene_nummer => self[:nummer], # --
        :szene_beschreibung => self[:beschreibung], # --

        :szene_grau => self[:grau], # --

        :szene_blickwinkel => self[:blickwinkel], # --
        :szene_prozent_z => self[:prozent_z], # --
        :szene_hoehe => self[:hoehe], # --
        :szene_breite => self[:breite], # --
        :szene_koordinate_x => self[:koordinate_x], # --
        :szene_koordinate_y => self[:koordinate_y], # --

        :szene_bild_polygon => self[:polygon], # --
        :szene_bild_rect => self[:rect], # --

        :stelle_uid => self.stellen.collect { |stelle| stelle.id}, # --
        :stelle_count => self.stellen.size, # --
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
