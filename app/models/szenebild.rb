require 'rsolr'

class Szenebild < ActiveRecord::Base


  #before_validation :check_data

  def self.fetch(
      dateiname,
          name,
          imagemap,
          breite,
          hoehe,
          breite_original,
          hoehe_original,
          offset_x,
          offset_y
  )

    Rails.cache.fetch("szenebild_#{dateiname}") {

      sb = Szenebild.new(
          dateiname:       dateiname,
          name:            name,
          imagemap:        imagemap,
          breite:          breite,
          hoehe:           hoehe,
          breite_original: breite_original,
          hoehe_original:  hoehe_original,
          offset_x:        offset_x,
          offset_y:        offset_y
      )

      sb.id = ActiveRecord::Base.connection.execute("select nextval('szenebilder_id_seq')").first['nextval']

      Rails.cache.write("szenebild_#{dateiname}", sb)

      return [sb]
    }


  end


end
