class AddConfirmedEventAirtableIdToEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :events, :confirmed_event_airtable_id, :string
  end
end
