class CreateCreatorPositionInvites < ActiveRecord::Migration[8.0]
  def change
    create_table :creator_position_invites do |t|
      t.references :project, null: false, foreign_key: true
      t.string :email
      t.string :token
      t.datetime :expires_at

      t.timestamps
    end
  end
end
