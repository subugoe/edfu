class CreateWbsberlin < ActiveRecord::Migration
  def change
    create_table :wbsberlin do |t|
      # t.string :uid
      t.string :band
      t.string :seite_start
      t.string :seite_stop
      t.string :zeile_start
      t.string :zeile_stop
      t.string :notiz
      t.belongs_to :wort

      #t.timestamps
    end
  end
end
