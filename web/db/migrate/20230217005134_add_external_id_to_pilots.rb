class AddExternalIdToPilots < ActiveRecord::Migration
  def change
    add_column :pilots, :external_id, :string
  end
end
