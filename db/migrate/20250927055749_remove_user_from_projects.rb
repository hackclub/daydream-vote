class RemoveUserFromProjects < ActiveRecord::Migration[8.0]
  def change
    remove_reference :projects, :user, null: false, foreign_key: true
  end
end
