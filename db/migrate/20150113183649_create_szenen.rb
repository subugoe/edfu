class CreateSzenen < ActiveRecord::Migration
  def change
    create_table :szenen do |t|

      #t.string :uid
      t.string :nummer
      t.string :beschreibung
      #t.string :szene_bild_uid
      t.string :rect
      t.string :polygon
      t.string :koordinate_x
      t.string :koordinate_y
      t.string :blickwinkel
      t.string :breite
      t.string :prozent_z
      t.string :hoehe
      t.string :grau
      t.string :name
      t.string :dateiname
      t.string :imagemap
      t.string :breite
      t.string :hoehe
      t.string :offset_x
      t.string :offset_y
      t.string :breite_original
      t.string :hoehe_original

      #t.references :stellen, polymorphic: true

      #t.timestamps
    end
  end
end
