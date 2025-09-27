class AddAirtableSyncToProjects < ActiveRecord::Migration[8.0]
  def change
    add_column :projects, :airtable_record_id, :string
    add_column :projects, :last_synced_to_airtable_at, :datetime
    add_index :projects, :airtable_record_id
  end
end
