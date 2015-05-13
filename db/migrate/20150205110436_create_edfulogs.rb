class CreateEdfulogs < ActiveRecord::Migration
  def change
    create_table :edfulogs do |t|

      #t.string :date
      t.string :level
      t.string :edfutype
      t.string :text
      t.string :column
      t.text :old
      t.text :new
      t.string :uid

      #t.timestamps null: false

    end

    add_index :edfulogs, :uid # , :unique => true
  end
end
