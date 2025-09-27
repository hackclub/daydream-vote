class AddOwnerEmailToEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :events, :owner_email, :string
  end
end
