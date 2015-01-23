class CreateStellenSzenen < ActiveRecord::Migration
  def change
    create_table :stellen_szenen, id: false do |t|

      t.belongs_to :stelle, index: true
      t.belongs_to :szene, index: true

      #t.timestamps
    end
    add_index :stellen_szenen, [:stelle_id, :szene_id], unique: true
    add_index :stellen_szenen, [:szene_id, :stelle_id], unique: true
  end
end
