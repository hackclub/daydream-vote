class AddVotingEnabledToEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :events, :voting_enabled, :boolean, default: false, null: false
  end
end
