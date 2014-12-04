class CreateOrte < ActiveRecord::Migration
  def change
    create_table :orte do |t|
      t.string :uid
      #t.string :bandseitezeile
      t.string :transliteration
      #t.string :transliteration_nosuffix
      t.string :ort
      t.string :lokalisation
      t.string :anmerkung
      # t.string :iStelle

      t.timestamps
    end
  end
end
