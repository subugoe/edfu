# encoding: utf-8 

require 'lib/edfu_numerics_conversion_helper'
require 'lib/edfu_model_helper'
require 'rsolr'

class WbBerlin < ActiveRecord::Base
  include EdfuNumericsConversionHelper
  extend EdfuModelHelper

  has_one :wort

  after_commit :add_to_solr

  def start
    return "#{self[:band]}#{'%03i' % self[:seite_start]}#{'%02i' % self[:zeile_start]}"
  end

  def sort
    return "#{self[:band]}#{'%03i' % self[:seite_start]}#{'%03i' % self[:zeile_start]}"
  end


  def berlin_display

    roemisch = dezimal_nach_roemisch(self[:band])

    if self[:seite_start].to_i == self[:seite_stop].to_i
      if self[:zeile_start].to_i == self[:zeile_stop].to_i
        return "#{roemisch}, #{'%03i' % self[:seite_start]}, #{'%02i' % self[:zeile_stop]}"
      else
        return "#{roemisch}, #{'%03i' % self[:seite_start]}, #{'%02i' % self[:zeile_start]} - #{'%02i' % self[:zeile_stop]}"
      end
    else
      return "#{roemisch}, #{'%03i' % self[:seite_start]}, #{'%02i' % self[:zeile_start]} - #{'%03i' % self[:seite_stop]}, #{'%02i' % self[:zeile_stop]}"
    end


  end


  private


  def add_to_solr

    # todo extract
    solr = RSolr.connect :url => 'http://localhost:8983/solr/collection1'
    solr.add (
                 {
                     :sql_uid => self.id,
                     :band => self[:band].to_i,
                     :seite_start => self[:seite_start].to_i,
                     :seite_stop => self[:seite_stop].to_i,
                     :zeile_start => self[:zeile_start].to_i,
                     :zeile_stop => self[:zeile_stop].to_i,
                     :typ => 'wb_berlin',
                     :id => "wb_berlin-#{self.id}"
                 }
             )
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
