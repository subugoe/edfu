require 'rsolr'

class Szene < ActiveRecord::Base
  extend EdfuModelHelper

  has_and_belongs_to_many :stellen, :dependent => :delete_all

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
        beschreibung:    checkValue(beschreibung),
        rect:            checkValue(rect),
        koordinate_x:    checkValue(koordinate_x),
        koordinate_y:    checkValue(koordinate_y),
        blickwinkel:     checkValue(blickwinkel),
        breite:          checkValue(breite),
        prozent_z:       checkValue(prozent_z),
        hoehe:           checkValue(hoehe),
        grau:            grau,
        polygon:         polygon,
        # aus szenebild
        name:            checkValue(name),
        dateiname:       checkValue(dateiname),
        imagemap:        imagemap,
        bild_breite:     checkValue(bild_breite),
        bild_hoehe:      checkValue(bild_hoehe),
        offset_x:        checkValue(offset_x),
        offset_y:        checkValue(offset_y),
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

        :szene_bild_name      => self.name, # --
        :szene_bild_dateiname => self.dateiname, # --

        :szene_bild_breite    => self.bild_breite, #  # --
        :szene_bild_hoehe     => self.bild_hoehe, #  # --

        :szene_bild_offset_x  => self.offset_x, # --
        :szene_bild_offset_y  => self.offset_y, # --

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




  # checks the value, and returns ' ' if value is ''. Solr will remuve values with '' whiche causes issues in the FE
  # Szene: The arrays passed in the »arrays« argument do not have identical numbers of values:
  # (uid: 1, nummer: 1, beschreibung: 0, bild_name: 1, bild_dateiname: 1, bild_hoehe: 1, bild_breite: 1, bild_offset_x: 1, bild_offset_y: 1, bild_rect: 1, koordinate_x: 1, koordinate_y: 1, breite: 1, hoehe: 1, prozent_z: 1, blickwinkel: 1)
  def self.checkValue(value)

    if (value == '' || value == nil)
      return ' '
    else
      value
    end

  end

  private

end
