require 'rsolr'

class Szene < ActiveRecord::Base
  extend EdfuModelHelper

  has_and_belongs_to_many :stellen, :dependent => :delete_all

  #after_commit :add_to_solr
  #before_validation :check_data


  @@szenen = Hash.new()

  def self.szenen
    return @@szenen
  end


  def self.fetch(
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
          # aus szenebild
          name,
          dateiname,
          imagemap,
          bild_breite,
          bild_hoehe,
          offset_x,
          offset_y,
          breite_original,
          hoehe_original,
          band,
          seiteStart

  )


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
        # aus szenebild
        name:            name,
        dateiname:       dateiname,
        imagemap:        imagemap,
        bild_breite:     bild_breite,
        bild_hoehe:      bild_hoehe,
        offset_x:        offset_x,
        offset_y:        offset_y,
        breite_original: breite_original,
        hoehe_original:  hoehe_original,
        band:            band,
        seiteStart:      seiteStart

    )


    sz.id                             = ActiveRecord::Base.connection.execute("select nextval('szenen_id_seq')").first['nextval']


    @@szenen["#{band}_#{seiteStart}"] = Array.new if @@szenen["#{band}_#{seiteStart}"] == nil
    @@szenen["#{band}_#{seiteStart}"] << sz


    return [sz]

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


  # def add_to_solr
  #
  #   solr = RSolr.connect :url => 'http://localhost:8983/solr/collection1'
  #   solr.add (to_solr_string)
  #   solr.commit
  #
  # end


end
