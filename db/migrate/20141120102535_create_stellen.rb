class CreateStellen < ActiveRecord::Migration
  def change
    create_table :stellen do |t|
      #t.string :uid              #   myStelle['uid']
      t.string :tempel
      t.string :band             # myStelle['band_uid']
      t.string :seite_start        # myStelle['seite_start']
      t.string :seite_stop         # myStelle['seite_stop']
      t.string :zeile_start        # myStelle['zeile_start']
      t.string :zeile_stop         # myStelle['zeile_stop']
      t.string :stelle_anmerkung    # myStelle['anmerkung']
      t.string :stelle_unsicher     # myStelle['stop_unsicher']
      # t.string :start
      # t.string :stop
      t.string :zerstoerung         # myStelle['zerstoerung']
      t.string :freigegeben         # myStelle['freigegeben']
      t.references :zugehoerigZu, polymorphic: true

      #t.timestamps
    end
    # add_index :stellen, :bandseitezeile # , :unique => true
    add_index :stellen, :band # , :unique => true
    add_index :stellen, :seite_start # , :unique => true
  end
end
