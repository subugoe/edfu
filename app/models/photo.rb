# encoding: utf-8

require 'edfu_model_helper'

class Photo < ActiveRecord::Base
  extend EdfuModelHelper


  has_and_belongs_to_many :formulare

  @@photos = Hash.new

  def self.fetch(pfad, name, typ, kommentar)

    #Rails.cache.fetch("photo_#{pfad}") {

    photo =@@photos["photo_#{pfad}"]

    return photo if photo != nil

    p           = Photo.new
    p.pfad      = pfad
    p.name      = name
    p.typ       = typ
    p.kommentar = kommentar

    p.id                      = ActiveRecord::Base.connection.execute("select nextval('photos_id_seq')").first['nextval']

    #Rails.cache.write("photo_#{pfad}", p)

    @@photos["photo_#{pfad}"] = p

    return [p]
    #}

  end

  # def after_commit
  #   Rails.cache.write("photo_#{self.pfad}", self)
  # end
  #
  # def after_destroy
  #   Rails.cache.delete("photo_#{self.pfad}")
  # end

end
