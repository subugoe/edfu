class CreateFormulare < ActiveRecord::Migration
  def change
    create_table :formulare do |t|
      t.string :uid
      t.text :transliteration
      t.text :transliteration_nosuffix
      t.text :uebersetzung
      t.string :texttyp
      #t.string :photo        # über photo tabelle und per assoziation referenziert
      #t.string :photo_pfad
      #t.string :photo_kommentar
      t.string :szeneID
      #t.string :literatur    # über literatur tabelle und per assoziation referenziert
      t.string :band        # bestandteil von stelle
      t.string :bandseite
      t.string :bandseitezeile
      #t.string :seitezeile  # bestandteil von stelle

      #t.timestamps
    end
    add_index :formulare, :bandseitezeile # , :unique => true
  end
end
