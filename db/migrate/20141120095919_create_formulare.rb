class CreateFormulare < ActiveRecord::Migration
  def change
    create_table :formulare do |t|
      t.string :uid
      t.string :transliteration
      t.string :transliteration_nosuffix
      t.string :uebersetzung
      t.string :texttyp
      #t.string :photo        # über photo tabelle und per assoziation referenziert
      #t.string :photo_pfad
      #t.string :photo_kommentar
      t.string :szeneID
      #t.string :literatur    # über literatur tabelle und per assoziation referenziert
      t.string :band        # bestandteil von stelle
      t.string :seitezeile  # bestandteil von stelle

      t.timestamps
    end
  end
end