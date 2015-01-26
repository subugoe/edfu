require 'rsolr'

class Szene < ActiveRecord::Base
  extend EdfuModelHelper

  has_and_belongs_to_many :stellen, :dependent => :delete_all
  # has_many :szenebilder

  #after_commit :add_to_solr
  #before_validation :check_data


  def self.fetch(
      filepath,
          nummer,
          beschreibung,
          rect,
          koordinate_x,
          koordinate_y,
          blickwinkel,
          breite,
          prozent_z,
          hoehe,
          grau,
          polygon,
          recordSzeneBild
  )

    Rails.cache.fetch("szene_#{filepath}_#{nummer}_#{beschreibung}_#{rect}_#{koordinate_x}_#{koordinate_y}_#{blickwinkel}") {

      sz = Szene.new(
          nummer:          nummer,
          beschreibung:    beschreibung,
          rect:            rect,
          koordinate_x:    koordinate_x,
          koordinate_y:    koordinate_y,
          blickwinkel:     blickwinkel,
          breite:          breite,
          prozent_z:       prozent_z,
          hoehe:           hoehe,
          grau:            grau,
          polygon:         polygon,
          name:            recordSzeneBild.name,
          dateiname:       recordSzeneBild.dateiname,
          imagemap:        recordSzeneBild.imagemap,
          bild_breite:          recordSzeneBild.breite,
          bild_hoehe:           recordSzeneBild.hoehe,
          offset_x:        recordSzeneBild.offset_x,
          offset_y:        recordSzeneBild.offset_y,
          breite_original: recordSzeneBild.breite_original,
          hoehe_original:  recordSzeneBild.hoehe_original
      )

      sz.id = ActiveRecord::Base.connection.execute("select nextval('szenen_id_seq')").first['nextval']

      puts sz.id

      Rails.cache.write("szene_#{filepath}_#{nummer}_#{beschreibung}_#{rect}_#{koordinate_x}_#{koordinate_y}_#{blickwinkel}", sz)
      return [sz]
    }


  end


  def to_solr_string


    return {

        #:sql_uid                  => self[:id],
        # from szenebild
        :szene_bild_name      => self.name, # --
        :szene_bild_dateiname => self.dateiname, # --

        :szene_bild_breite    => self.bild_breite, #  # --
        :szene_bild_hoehe     => self.bild_hoehe, #  # --

        :szene_bild_offset_x  => self.offset_x, # --
        :szene_bild_offset_y  => self.offset_y, # --

        #:imagemap             => self.imagemap,
        #:breite_original      => self.breite_original,
        #:hoehe_original       => self.hoehe_original,

        # from szene

        :typ                  => 'szene', # --
        :id                   => "szene-#{self[:id]}", # --
        :szene_uid            => self[:id], # --

        :szene_nummer         => self[:nummer], # --
        :szene_beschreibung   => self[:beschreibung], # --

        :szene_grau           => self[:grau], # --

        :szene_blickwinkel    => self[:blickwinkel], # --
        :szene_prozent_z      => self[:prozent_z], # --
        :szene_hoehe          => self.hoehe, # --
        :szene_breite         => self.breite, # --
        :szene_koordinate_x   => self[:koordinate_x], # --
        :szene_koordinate_y   => self[:koordinate_y], # --

        :szene_bild_polygon   => self[:polygon], # --
        :szene_bild_rect      => self[:rect], # --

        :stelle_uid           => self.stellen.collect { |stelle| stelle.id }, # --
        :stelle_count         => self.stellen.size, # --
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
