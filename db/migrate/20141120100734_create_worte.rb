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
      #t.references :wbberlin, index: true

      #t.string :band             # bestandteil von stelle
      #t.string :bandseite        # bestandteil von stelle
      #t.string :bandseitezeile   # bestandteil von stelle

      #t.timestamps
    end
    #add_index :worte, :bandseitezeile # , :unique => true
  end
end
