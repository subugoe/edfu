# -*- coding: utf-8 -*-

require 'rsolr'

class Gott < ActiveRecord::Base
  include EdfuSolrHelper
  extend EdfuModelHelper


  has_many :stellen, as: :zugehoerigZu, :dependent => :delete_all

  attr_accessor :szenen


  def to_solr_string

    model = "GL-Model"
    spalte = "SEITEZEILE"

    h = {
        :sql_uid                  => self[:uid],
        :transliteration          => self[:transliteration],
        :transliteration_nosuffix => self[:transliteration_nosuffix],
        :ort                      => self[:ort],
        :eponym                   => self[:eponym],
        :beziehung                => self[:beziehung],
        :funktion                 => self[:funktion],
        :anmerkung                => self[:anmerkung],

        :typ                      => 'gott',
        :id                       => "gott-#{self[:uid]}",

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
