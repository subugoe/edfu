# encoding: utf-8

require 'edfu_model_helper'

class Photo < ActiveRecord::Base
  extend EdfuModelHelper


  has_and_belongs_to_many :formulare
end
