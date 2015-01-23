class CreateUploads < ActiveRecord::Migration
  def change
    create_table :uploads do |t|

      # todo add email for notification

      t.string :formular
      t.string :ort
      t.string :gott
      t.string :wort

      t.string :email

      #t.timestamps
    end
  end
end
