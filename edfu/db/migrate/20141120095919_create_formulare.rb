class CreateFormulare < ActiveRecord::Migration
  def change
    create_table :formulare do |t|
      t.string :uid
      t.string :transliteration
      t.string :transliteration_nosuffix
      t.string :uebersetzung
      t.string :texttyp
      t.string :photo
      t.string :photo_pfad
      t.string :photo_kommentar
      t.string :szeneID
      t.string :literatur
      t.string :band
      t.string :seitenzeile

      t.timestamps
    end
  end
end
