class AddAttendingEventToProjects < ActiveRecord::Migration[8.0]
  def change
    add_column :projects, :attending_event, :integer
  end
end
