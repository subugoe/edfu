class Literatur < ActiveRecord::Base
  has_and_belongs_to_many :formulare
end
