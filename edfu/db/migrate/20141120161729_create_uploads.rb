class CreateUploads < ActiveRecord::Migration
  def change
    create_table :uploads do |t|
      t.string :formular
      t.string :ort
      t.string :gott
      t.string :wort

      t.timestamps
    end
  end
end
