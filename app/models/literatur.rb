# encoding: utf-8

class Literatur < ActiveRecord::Base
  extend EdfuModelHelper

  has_and_belongs_to_many :formulare

  @@literaturen = Hash.new

  def self.fetch(beschreibung, detail)

    lit = @@literaturen["literatur_#{beschreibung}_#{detail}"]

    return lit if lit != nil

    l              = Literatur.new
    l.beschreibung = beschreibung
    l.detail       = detail

    l.id                                               = ActiveRecord::Base.connection.execute("select nextval('literaturen_id_seq')").first['nextval']

    @@literaturen["literatur_#{beschreibung}_#{detail}"] = l

    return [l]

  end

end
