class FormularePhotos < ActiveRecord::Base
  belongs_to :formular
  belongs_to :photo
end