class RemoveAttendingEventFromProfileData < ActiveRecord::Migration[8.0]
  def change
    remove_column :profile_data, :attending_event, :integer
  end
end
