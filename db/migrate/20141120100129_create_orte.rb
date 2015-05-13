class CreateOrte < ActiveRecord::Migration
  def change
    create_table :orte do |t|
      t.string :uid
      #t.string :bandseitezeile
      t.string :transliteration
      t.string :transliteration_nosuffix
      t.string :ort
      t.string :lokalisation
      t.string :anmerkung
      # t.string :iStelle

      #t.string :band             # bestandteil von stelle
      #t.string :bandseite        # bestandteil von stelle
      #t.string :bandseitezeile   # bestandteil von stelle


      #t.timestamps
    end
    # add_index :orte, :bandseitezeile # , :unique => true
  end
end
