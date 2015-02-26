# encoding: utf-8 

require 'edfu_model_helper'
require 'edfu_solr_helper'
require 'rsolr'
# require 'celluloid/autostart'

class Ort < ActiveRecord::Base
  include EdfuSolrHelper
  extend EdfuModelHelper

  has_many :stellen, as: :zugehoerigZu, :dependent => :delete_all

  attr_accessor :szenen

  def transliteration_nosuffix
    return self.transliteration
  end

  def transliteration_nosuffix= tn
    self.transliteration= tn
  end

  def to_solr_string

    model = "OL-Model"
    spalte = "STELLE"

    h = {
        :sql_uid                  => self[:uid],
        :transliteration          => self[:transliteration],
        :transliteration_nosuffix => self[:transliteration],
        :ort                      => self[:ort],
        :lokalisation             => self[:lokalisation],
        :anmerkung                => self[:anmerkung],

        :typ                      => 'ort',
        :id                       => "ort-#{self[:uid]}",
    }

    # --- add stellen

    h.merge!(stellenHash(model, spalte, :transliteration))

    # --- add szene

    if self.szenen !=nil && self.szenen.size > 0
      h.merge!(szenenHash)
    end

    return h

  end


  private

end