# encoding: utf-8

require 'edfu_model_helper'
require 'rsolr'
#require 'celluloid/autostart'

class Formular < ActiveRecord::Base
  extend EdfuModelHelper

  # iXYZ - 'i' for imported
  attr_accessor :iphoto, :photo_kommentar, :iliteratur

  # todo has_many or has_one?
  has_many :stellen, as: :zugehoerigZu, :dependent => :delete_all

  has_and_belongs_to_many :photos, :dependent => :delete_all
  has_and_belongs_to_many :literaturen, :dependent => :delete_all

  #after_commit :add_to_solr
  #before_validation :check_data


  def to_solr_string

    begin
      stelle = self.stellen.first.start
    rescue NoMethodError
      puts "problem mit solr-sort: für uid: #{self.uid} (formular)"
      stelle = ''
    end

    return {
        :sql_uid                  => self[:uid], # ---

        :sort => stelle, # ---  todo

        :transliteration          => self[:transliteration], # ---

        :transliteration_nosuffix => self[:transliteration], #
        :uebersetzung             => self[:uebersetzung], # ---
        :texttyp                  => self[:texttyp], # ---
        :szene_nummer             => self[:szeneID], #  todo stimmt szene_nummer = SzeneID ?

        :photo                    => self.photos.collect { |photo| photo.name }, # ---
        :photo_kommentar          => self.photos.collect { |photo| photo.kommentar }, # ---
        :photo_pfad               => self.photos.collect { |photo| photo.pfad }, # ---

        :literatur                => self.literaturen.collect { |lit| "#{lit.beschreibung} : #{lit.detail}" }, # ---

        :stelle_id                => self.stellen.collect { |stelle| "stelle-#{stelle.id}" }, # ---
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

        :typ                      => 'formular', # ---
        :id                       => "formular-#{self[:uid]}" # ---
    }
  end

  def to_s
    return "#{self[:uid]}" #,

    # #{self[:transliteration]},
    # #{self[:transliteration]},
    # #{self[:uebersetzung]},
    # #{self[:texttyp]},
    # #{self[:szeneID]},
    # #{self.photos.collect { |photo| photo.name }},
    # #{self.photos.collect { |photo| photo.kommentar }},
    # #{self.photos.collect { |photo| photo.pfad }},
    # #{self.literaturen.collect { |lit| "#{lit.beschreibung} : #{lit.detail}" }},
    # #{self.stellen.collect { |stelle| "stelle-#{stelle.id}" }},
    # #{self.stellen.collect { |stelle| stelle.band }},
    # #{self.stellen.collect { |stelle| stelle.bandseite }},
    # #{self.stellen.collect { |stelle| stelle.bandseitezeile }},
    # #{self.stellen.collect { |stelle| stelle.seite_start }},
    # #{self.stellen.collect { |stelle| stelle.seite_stop }},
    # #{self.stellen.collect { |stelle| stelle.zeile_start }},
    # #{self.stellen.collect { |stelle| stelle.zeile_stop }},
    # #{self.stellen.collect { |stelle| stelle.zerstoerung }},
    # #{self.stellen.collect { |stelle| stelle.freigegeben }},
    # #{self.stellen.collect { |stelle| stelle.stelle_unsicher }},
    # #{self.stellen.collect { |stelle| stelle.stelle_anmerkung }},
    # 'formular',
    # formular-#{self[:uid]}"
  end


  private


  def add_to_solr

    # todo extract
    solr = RSolr.connect :url => 'http://localhost:8983/solr/collection1'
    solr.add (to_solr_string)
    solr.commit
  end

  # todo update solr doc
  # todo log updated
  def log_updated
    logger.debug "[DEBUG]  after update: #{id}"
  end


  # todo add doc to solr
  # todo log created
  def log_created
    logger.debug "[DEBUG]  before save: #{id}"
  end

end






