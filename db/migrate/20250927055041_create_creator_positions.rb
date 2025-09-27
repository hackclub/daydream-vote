class CreateCreatorPositions < ActiveRecord::Migration[8.0]
  def change
    create_table :creator_positions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :project, null: false, foreign_key: true

      t.timestamps
    end
  end
end
