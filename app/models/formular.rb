# encoding: utf-8

require 'edfu_model_helper'
require 'rsolr'
#require 'celluloid/autostart'

class Formular < ActiveRecord::Base
  include EdfuSolrHelper
  extend EdfuModelHelper

  # iXYZ - 'i' for imported
  attr_accessor :iphoto, :photo_kommentar, :iliteratur, :szenen


  has_many :stellen, as: :zugehoerigZu, :dependent => :delete_all

  has_and_belongs_to_many :photos, :dependent => :delete_all
  has_and_belongs_to_many :literaturen, :dependent => :delete_all


  def to_solr_string

    model  = "FL-Model"
    spalte = "SEITEZEILE"


    h = {
        :sql_uid                  => self[:uid], # ---
        :transliteration          => self[:transliteration], # ---
        :transliteration_nosuffix => self[:transliteration_nosuffix], #
        :uebersetzung             => self[:uebersetzung], # ---
        :texttyp                  => self[:texttyp], # ---
        :szene_nummer             => self[:szeneID], #

        :photo                    => self.photos.collect { |photo| photo.name }, # ---
        :photo_kommentar          => self.photos.collect { |photo| photo.kommentar.to_s }, # ---
        :photo_pfad               => self.photos.collect { |photo| photo.pfad }, # ---

        :literatur                => self.literaturen.collect { |lit| "#{lit.beschreibung} : #{lit.detail}" }, # ---

        :typ                      => 'formular',
        :id                       => "formular-#{self[:uid]}",
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






