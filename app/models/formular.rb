# encoding: utf-8

require 'edfu_model_helper'
require 'rsolr'
#require 'celluloid/autostart'

class Formular < ActiveRecord::Base
  extend EdfuModelHelper

  # iXYZ - 'i' for imported
  attr_accessor :iphoto, :photo_kommentar, :iliteratur


  has_many :stellen, as: :zugehoerigZu, :dependent => :delete_all

  has_and_belongs_to_many :photos, :dependent => :delete_all
  has_and_belongs_to_many :literaturen, :dependent => :delete_all


  def to_solr_string

    begin
      stelle = self.stellen.first.start
    rescue NoMethodError
      EdfuLog.new("ERROR", "FL-Model", "Fehlerhafter Start in Seitezeile (solr sort daher '' statt '<stelle>')", "SEITEZEILE", '', '', self.uid)
      stelle = ''
    end

    return {
        :sql_uid                  => self[:uid], # ---

        :sort                     => stelle, # ---

        :transliteration          => self[:transliteration], # ---

        :transliteration_nosuffix => self[:transliteration_nosuffix], #
        :uebersetzung             => self[:uebersetzung], # ---
        :texttyp                  => self[:texttyp], # ---
        :szene_nummer             => self[:szeneID], #

        :photo                    => self.photos.collect { |photo| photo.name }, # ---
        :photo_kommentar          => self.photos.collect { |photo| photo.kommentar }, # ---
        :photo_pfad               => self.photos.collect { |photo| photo.pfad }, # ---

        :literatur                => self.literaturen.collect { |lit| "#{lit.beschreibung} : #{lit.detail}" }, # ---

        :band                     => self.stellen.collect { |stelle| stelle.band }, # ---
        :bandseite                => self.stellen.collect { |stelle| stelle.bandseite }, # ---
        :bandseitezeile           => self.stellen.collect { |stelle| stelle.bandseitezeile }, # ---


        :seite_start              => self.stellen.collect { |stelle| stelle.seite_start }, # ---
        :seite_stop               => self.stellen.collect { |stelle| stelle.seite_stop }, # ---
        :zeile_start              => self.stellen.collect { |stelle| stelle.zeile_start }, # ---
        :zeile_stop               => self.stellen.collect { |stelle| stelle.zeile_stop }, # ---

        :zerstoerung              => self.stellen.collect { |stelle| stelle.zerstoerung }, # ---
        :freigegeben              => self.stellen.collect { |stelle| stelle.freigegeben }, # ---
        :stelle_unsicher          => self.stellen.collect { |stelle| stelle.stelle_unsicher }, # ---
        :stelle_anmerkung         => self.stellen.collect { |stelle| stelle.stelle_anmerkung }, # ---

        :stelle_id                => self.stellen.collect { |stelle| "stelle-#{stelle.id}" }, # ---

        :typ                      => 'formular', # ---
        :id                       => "formular-#{self[:uid]}" # ---
    }
  end


  private


  def add_to_solr

    solr = RSolr.connect :url => 'http://localhost:8983/solr/collection1'
    solr.add (to_solr_string)
    solr.commit

  end

end






