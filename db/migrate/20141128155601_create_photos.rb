class CreatePhotos < ActiveRecord::Migration
  def change
    create_table :photos do |t|

      t.string :name
      t.string :typ
      t.string :pfad
      t.text :kommentar

      t.timestamps
    end
  end
end
