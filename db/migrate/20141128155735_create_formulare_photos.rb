class CreateFormularePhotos < ActiveRecord::Migration
  def change
    create_table :formulare_photos, id: false do |t|
      t.belongs_to :formular, index: true
      t.belongs_to :photo, index: true

      t.timestamps
    end
    add_index :formulare_photos, [:formular_id, :photo_id], unique: true
    add_index :formulare_photos, [:photo_id, :formular_id], unique: true

  end
end
