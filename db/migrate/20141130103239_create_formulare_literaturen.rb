class CreateFormulareLiteraturen < ActiveRecord::Migration
  def change
    create_table :formulare_literaturen, id: false do |t|
      t.belongs_to :formular, index: true
      t.belongs_to :literatur, index: true

      t.timestamps
    end
  end
end
