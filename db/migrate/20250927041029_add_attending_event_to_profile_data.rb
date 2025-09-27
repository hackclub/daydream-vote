class AddAttendingEventToProfileData < ActiveRecord::Migration[8.0]
  def change
    add_column :profile_data, :attending_event, :integer
  end
end
