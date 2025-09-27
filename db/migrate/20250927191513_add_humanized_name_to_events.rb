class AddHumanizedNameToEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :events, :humanized_name, :string
  end
end
