# encoding: utf-8 

require 'edfu_model_helper'
require 'edfu_solr_helper'
#require 'edfu_numerics_conversion_helper'
require 'rsolr'
#require 'celluloid/autostart'

class Gott < ActiveRecord::Base
  include EdfuDataMappings, EdfuSolrHelper
  extend EdfuModelHelper


  has_many :stellen, as: :zugehoerigZu, :dependent => :delete_all

  attr_accessor :transliteration_nosuffix, :szenen


  def to_solr_string

    model = "GL-Model"
    spalte = "SEITEZEILE"

    h = {
        :sql_uid                  => self[:uid], # ---
        :transliteration          => self[:transliteration], # ---
        :transliteration_nosuffix => self[:transliteration], # ? ---
        :ort                      => self[:ort], # ---
        :eponym                   => self[:eponym], # ---
        :beziehung                => self[:beziehung], # ---
        :funktion                 => self[:funktion], # ---
        :anmerkung                => self[:anmerkung], # ---

        :typ                      => 'gott', # ---
        :id                       => "gott-#{self[:uid]}", # ---

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
