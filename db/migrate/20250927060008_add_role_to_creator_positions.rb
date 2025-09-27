class AddRoleToCreatorPositions < ActiveRecord::Migration[8.0]
  def change
    add_column :creator_positions, :role, :integer, default: 1, null: false
    add_index :creator_positions, :role
  end
end
