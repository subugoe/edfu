# encoding: utf-8 

require 'rsolr'

class Stelle < ActiveRecord::Base
  extend EdfuModelHelper

  attr_accessor :start, :stop

  belongs_to :zugehoerigZu, polymorphic: true
  has_and_belongs_to_many :szenen, :dependent => :delete_all

  # changed from hash to array, because earlier for stellen would be overwritten
  @@stellen = Array.new

  def self.stellen
    return @@stellen
  end

  def start
    return "#{self[:band]}#{'%03i' % self[:seite_start]}#{'%03i' % self[:zeile_start]}"
  end

  def stop
    return "#{self[:band]}#{'%03i' % self[:seite_stop]}#{'%03i' % self[:zeile_stop]}"
  end

  def to_solr_string
    return {
        :sql_uid          => self[:id],

        :tempel           => self.tempel,

        :band             => self.band,
        :bandseite        => self.bandseite,
        :bandseitezeile   => self.bandseitezeile,
        :seite_start      => self.seite_start,
        :seite_stop       => self.seite_stop,
        :zeile_start      => self.zeile_start,
        :zeile_stop       => self.zeile_stop,
        :start            => self.start,
        :stop             => self.stop,

        :freigegeben      => self.freigegeben,
        :zerstoerung      => self.zerstoerung,

        :stelle_anmerkung => self.stelle_anmerkung,
        :stelle_unsicher  => self.stelle_unsicher,

        :besitzer         => "#{self.zugehoerigZu_type.downcase}-#{self.zugehoerigZu_id}",

        :typ              => 'stelle',
        :id               => "stelle-#{self[:id]}"

        # todo: add szene?
    }
  end

  # checks the value, and returns ' ' if value is ''. Solr will remuve values with '' whiche causes issues in the FE
  # STELLE: The arrays passed in the »arrays« argument do not have identical numbers of values:
  #   (bandseitezeile: 0, band: 0, seite_start: 0, seite_stop: 0, zeile_start: 0, zeile_stop: 0, unsicher: 0, zerstoerung: 0, anmerkung: 0)
  def self.checkValue(value)

    if (value == '' || value == nil)
      return ' '
    else
      value
    end

  end

  def self.fetch(
      typ,
          tempel,
          band,
          bandseite,
          bandseitezeile,
          seite_start,
          seite_stop,
          zeile_start,
          zeile_stop,
          stelle_anmerkung,
          stelle_unsicher,
          zerstoerung,
          freigegeben
  )

    s = Stelle.new(
        tempel:           tempel,
        band:             checkValue(band),
        bandseite:        checkValue(bandseite),
        bandseitezeile:   checkValue(bandseitezeile),
        seite_start:      checkValue(seite_start),
        seite_stop:       checkValue(seite_stop),
        zeile_start:      checkValue(zeile_start),
        zeile_stop:       checkValue(zeile_stop),
        stelle_anmerkung: checkValue(stelle_anmerkung),
        stelle_unsicher:  stelle_unsicher,
        zerstoerung:      zerstoerung,
        freigegeben:      freigegeben
    )

    s.id = ActiveRecord::Base.connection.execute("select nextval('stellen_id_seq')").first['nextval']

    @@stellen << s

    return s

  end

  private

end

