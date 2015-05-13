# encoding: utf-8 

require 'rsolr'

class Wbberlin < ActiveRecord::Base
  include EdfuDataMappings
  extend EdfuModelHelper

  belongs_to :wort


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

  def to_solr_string
    return {
        :sql_uid => self.id,
        :band => self[:band].to_i,
        :seite_start => self[:seite_start].to_i,
        :seite_stop => self[:seite_stop].to_i,
        :zeile_start => self[:zeile_start].to_i,
        :zeile_stop => self[:zeile_stop].to_i,
        :typ => 'wb_berlin',
        :id => "wb_berlin-#{self.id}"
    }
  end

  private

end
