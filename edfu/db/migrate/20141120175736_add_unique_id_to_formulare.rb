class AddUniqueIdToFormulare < ActiveRecord::Migration
  def change
    add_column :formulare, :uniqueID, :string
  end
end
