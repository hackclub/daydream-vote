class CreateOrganizerPositions < ActiveRecord::Migration[8.0]
  def change
    create_table :organizer_positions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :event, null: false, foreign_key: true

      t.timestamps
    end
    
    add_index :organizer_positions, [:user_id, :event_id], unique: true
  end
end
