class CreateEdfuStatuses < ActiveRecord::Migration
  def change
    create_table :edfu_statuses do |t|
      t.string :email
      t.string :status
      t.string :message

      t.timestamps null: false
    end
  end
end
