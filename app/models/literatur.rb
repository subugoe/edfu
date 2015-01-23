# encoding: utf-8


class Literatur < ActiveRecord::Base
  extend EdfuModelHelper

  has_and_belongs_to_many :formulare

  def self.fetch(beschreibung, detail)

    Rails.cache.fetch("literatur_#{beschreibung}_#{detail}") {

      l              = Literatur.new
      l.beschreibung = beschreibung
      l.detail       = detail

      l.id = ActiveRecord::Base.connection.execute("select nextval('literaturen_id_seq')").first['nextval']

      Rails.cache.write("literatur_#{beschreibung}_#{detail}", l)

      return [l]
    }

  end

  # def after_commit
  #   Rails.cache.write("literatur_#{self.beschreibung}_#{self.detail}", self)
  # end
  #
  # def after_destroy
  #   Rails.cache.delete("literatur_#{self.beschreibung}_#{self.detail}")
  # end

end
