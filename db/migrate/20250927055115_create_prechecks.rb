class CreatePrechecks < ActiveRecord::Migration[8.0]
  def change
    create_table :prechecks do |t|
      t.references :project, null: false, foreign_key: true
      t.integer :status
      t.text :message

      t.timestamps
    end
  end
end
