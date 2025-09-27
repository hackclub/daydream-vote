class AddHiddenToProjects < ActiveRecord::Migration[8.0]
  def change
    add_column :projects, :hidden, :boolean, default: false, null: false
  end
end
