class CreateSzenebilder < ActiveRecord::Migration
  def change
    create_table :szenebilder do |t|

      # t.string :uid
      t.string :name
      t.string :dateiname
      t.string :imagemap
      t.string :breite
      t.string :hoehe
      t.string :offset_x
      t.string :offset_y
      t.string :breite_original
      t.string :hoehe_original

      t.belongs_to :szene, index: true

      t.timestamps
    end
  end
end
