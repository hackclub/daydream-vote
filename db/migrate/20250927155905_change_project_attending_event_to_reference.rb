class ChangeProjectAttendingEventToReference < ActiveRecord::Migration[8.0]
  def change
    remove_column :projects, :attending_event, :integer
    add_reference :projects, :attending_event, foreign_key: { to_table: :events }, null: false
  end
end
