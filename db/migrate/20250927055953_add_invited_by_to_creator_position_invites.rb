class AddInvitedByToCreatorPositionInvites < ActiveRecord::Migration[8.0]
  def change
    add_reference :creator_position_invites, :invited_by, null: false, foreign_key: { to_table: :users }, index: true
  end
end
