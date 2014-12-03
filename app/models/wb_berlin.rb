# encoding: utf-8 

require 'lib/edfu_model_helper'
require 'rubygems'
require 'rsolr'

class WbBerlin < ActiveRecord::Base
  extend EdfuModelHelper

  has_one :wort

  # after_update :log_updated
  # after_create :log_created
  after_commit :add_to_solr

  # searchable do
  #
  #   integer :uid, stored: true
  #   integer :band, stored: true
  #   integer :seite_start, stored: true
  #   integer :seite_stop, stored: true
  #   integer :zeile_start, stored: true
  #   integer :zeile_stop, stored: true
  #   # t.references :wort, stored: true
  #   # todo id hinzufügen, typ hinzufügen,
  #
  # end


  private


  def add_to_solr


    solr = RSolr.connect :url => 'http://localhost:8983/solr/collection1'

    solr.add ({
        :sql_uid => self.id,
        :band => self[:band],
        :seite_start => self[:seite_start],
        :seite_stop => self[:seite_stop],
        :zeile_start => self[:zeile_start],
        :zeile_stop => self[:zeile_stop],
        :typ => 'wb_berlin',
        :id => "wb_berlin-#{self.id}"})
    #   # todo id hinzufügen, typ hinzufügen,

    solr.commit


  end


  # todo update solr doc
  # todo log updated
  def log_updated
    logger.info "[INFO]  after update: #{id}"
  end


  # todo add doc to solr
  # todo log created
  def log_created

    logger.info "---- in: log_created"

  end


end
