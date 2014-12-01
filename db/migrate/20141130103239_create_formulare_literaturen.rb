class CreateFormulareLiteraturen < ActiveRecord::Migration
  def change
    create_table :formulare_literaturen, id: false do |t|
      t.belongs_to :formular, index: true
      t.belongs_to :literatur, index: true

      t.timestamps
    end
    add_index :formulare_literaturen, [:formular_id, :literatur_id], unique: true
    add_index :formulare_literaturen, [:literatur_id, :formular_id], unique: true

  end
end
