require 'rsolr'

class Szenebild < ActiveRecord::Base

  attr_accessor :name, :dateiname, :imagemap, :breite, :hoehe,  :offset_x,  :offset_y,  :breite_original,  :hoehe_original


end
