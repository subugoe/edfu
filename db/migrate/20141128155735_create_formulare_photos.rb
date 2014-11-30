class CreateFormularePhotos < ActiveRecord::Migration
  def change
    create_table :formulare_photos, id: false do |t|
      t.belongs_to :formular, index: true
      t.belongs_to :photo, index: true

      t.timestamps
    end
  end
end
