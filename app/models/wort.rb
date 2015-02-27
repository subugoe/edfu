# encoding: utf-8 

require 'rsolr'

class Wort < ActiveRecord::Base
  include EdfuSolrHelper
  extend EdfuModelHelper

  has_one :wbberlin
  has_many :stellen, as: :zugehoerigZu, :dependent => :delete_all

  attr_accessor :szenen

  def to_solr_string

    model = "GL-Model"
    spalte = "BelegstelleEdfu"

    h = {
        :sql_uid                  => self[:uid],
        :transliteration          => self[:transliteration],
        :transliteration_nosuffix => self[:transliteration],
        :uebersetzung             => self[:uebersetzung],
        :hieroglyph               => self[:hieroglyph],
        :weiteres                 => self[:weiteres],
        :anmerkung                => self[:anmerkung],

        :berlin_display           => self.wbberlin.berlin_display,
        :berlin_band              => self.wbberlin.band.to_i,
        :berlin_seite_start       => self.wbberlin.seite_start.to_i,
        :berlin_seite_stop        => self.wbberlin.seite_stop.to_i,
        :berlin_zeile_start       => self.wbberlin.zeile_start.to_i,
        :berlin_zeile_stop        => self.wbberlin.zeile_stop.to_i,
        :stelle_berlin_id         => self.wbberlin.id,

        :typ                      => 'wort',
        :id                       => "wort-#{self[:uid]}",
    }

    # --- add stellen

    h.merge!(stellenHash(model, spalte, nil))

    # --- add szene

    if self.szenen !=nil && self.szenen.size > 0
      h.merge!(szenenHash)
    end


    return h

  end

  private

end
