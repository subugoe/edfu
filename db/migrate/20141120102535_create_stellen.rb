class CreateStellen < ActiveRecord::Migration
  def change
    create_table :stellen do |t|
      t.string :uid
      t.string :tempel
      t.string :band
      t.string :bandseite
      t.string :bandseitezeile
      t.string :seite_start
      t.string :seite_stop
      t.string :zeile_start
      t.string :zeile_stop
      t.string :stelle_anmerkung
      t.string :stelle_unsicher
      t.string :start
      t.string :stop
      t.string :zerstoerung
      t.string :freigegeben
      t.references :zugehoerigZu, polymorphic: true

      t.timestamps
    end
  end
end
