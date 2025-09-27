class AddSubmittedAtToProjects < ActiveRecord::Migration[8.0]
  def change
    add_column :projects, :submitted_at, :datetime
  end
end
