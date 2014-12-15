class CreateWorte < ActiveRecord::Migration
  def change
    create_table :worte do |t|
      t.string :uid
      t.string :transliteration
      t.string :transliteration_nosuffix
      t.string :uebersetzung
      t.string :hieroglyph
      t.string :weiteres
      t.string :belegstellenEdfu
      t.string :belegstellenWb
      t.string :anmerkung
      t.references :wbberlin, index: true

      t.timestamps
    end
  end
end
