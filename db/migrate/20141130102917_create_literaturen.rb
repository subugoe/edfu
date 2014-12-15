class CreateLiteraturen < ActiveRecord::Migration
  def change
    create_table :literaturen do |t|

      t.string :beschreibung
      t.string :detail

      t.timestamps
    end
    add_index :literaturen, [:beschreibung, :detail]
  end
end
