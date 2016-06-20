# -*- coding: utf-8 -*-

class Photo < ActiveRecord::Base
  extend EdfuModelHelper


  has_and_belongs_to_many :formulare

  @@photos = Hash.new

  def self.fetch(pfad, name, typ, kommentar)

    photo =@@photos["photo_#{pfad}"]

    return photo if photo != nil

    kommentar = ' ' if kommentar == ''

    p           = Photo.new
    p.pfad      = pfad
    p.name      = name
    p.typ       = typ
    p.kommentar = kommentar

    p.id                      = ActiveRecord::Base.connection.execute("select nextval('photos_id_seq')").first['nextval']

    @@photos["photo_#{pfad}"] = p

    return [p]

  end

end
