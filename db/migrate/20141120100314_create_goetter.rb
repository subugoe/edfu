class CreateGoetter < ActiveRecord::Migration
  def change
    create_table :goetter do |t|
      t.string :uid
      t.string :transliteration
      # t.string :transliteration_nosuffix
      t.string :ort
      t.string :eponym
      t.string :beziehung
      t.string :funktion
      t.string :band
      t.string :seitezeile
      t.string :anmerkung

      t.timestamps
    end
  end
end
