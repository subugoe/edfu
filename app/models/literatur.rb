# encoding: utf-8


class Literatur < ActiveRecord::Base
  extend EdfuModelHelper


  has_and_belongs_to_many :formulare
end
