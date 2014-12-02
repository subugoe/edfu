class CreateWbBerlins < ActiveRecord::Migration
  def change
    create_table :wb_berlins do |t|
      # t.string :uid
      t.string :band
      t.string :seite_start
      t.string :seite_stop
      t.string :zeile_start
      t.string :zeile_stop
      t.string :notiz
      t.references :wort, index: true

      t.timestamps
    end
  end
end
