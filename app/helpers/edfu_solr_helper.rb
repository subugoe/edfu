module EdfuSolrHelper

  def stellenHash(model, spalte, transliteration)

    if (self.stellen.size == 0)
      #stelle_freigegeben = ' '
      stelle_zerstoerung = false
      stelle_unsicher    = true
      stelle_anmerkung   = ' '

      stelle_seite_start = 0
      stelle_seite_stop  = 0
      stelle_zeile_start = 0
      stelle_zeile_stop  = 0

      stelle_band           = 0
      #stelle_bandseite      = ' '
      stelle_bandseitezeile = ' '

      #stelle_id = ' '

      stelle                = ''

      Edfulog.new("ERROR", model, "Fehlerhafte STELLE", spalte, '', '', self.uid)

    else
      stelle_freigegeben = self.stellen.collect { |stelle| stelle.freigegeben }
      stelle_zerstoerung = self.stellen.collect { |stelle| stelle.zerstoerung }
      stelle_unsicher    = self.stellen.collect { |stelle| stelle.stelle_unsicher }
      stelle_anmerkung   = self.stellen.collect { |stelle| stelle.stelle_anmerkung }

      stelle_seite_start = self.stellen.collect { |stelle| stelle.seite_start }
      stelle_seite_stop  = self.stellen.collect { |stelle| stelle.seite_stop }
      stelle_zeile_start = self.stellen.collect { |stelle| stelle.zeile_start }
      stelle_zeile_stop  = self.stellen.collect { |stelle| stelle.zeile_stop }

      stelle_band           = self.stellen.collect { |stelle| stelle.band }
      stelle_bandseite      = self.stellen.collect { |stelle| stelle.bandseite }
      stelle_bandseitezeile = self.stellen.collect { |stelle| stelle.bandseitezeile }

      stelle_id = self.stellen.collect { |stelle| "stelle-#{stelle.id}" }

      stelle = self.stellen.first.start
    end

    case model
      when "GL-Model"
        sort                     = "Act--#{stelle}"
      when "FL-Model"
        sort                     = stelle
      when "OL-Model"
        sort                     = "#{transliteration}--#{stelle}"
      when "WL-Model"
        sort                     = "Ddt--#{stelle}"
      else
        puts "You just making it up!"
    end

    return {
        :freigegeben              => stelle_freigegeben,
        :zerstoerung              => stelle_zerstoerung,
        :stelle_unsicher          => stelle_unsicher,
        :stelle_anmerkung         => stelle_anmerkung,

        :seite_start              => stelle_seite_start,
        :seite_stop               => stelle_seite_stop,
        :zeile_start              => stelle_zeile_start,
        :zeile_stop               => stelle_zeile_stop,

        :band                     => stelle_band,
        :bandseite                => stelle_bandseite,
        :bandseitezeile           => stelle_bandseitezeile,

        :stelle_id                => stelle_id,
        :sort                     => "Act--#{stelle}"
    }
  end

  def szenenHash
    return {
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
    }
  end

end