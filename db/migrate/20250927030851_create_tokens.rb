class CreateTokens < ActiveRecord::Migration[8.0]
  def change
    create_table :tokens, id: false do |t|
      t.string :id, primary_key: true
      t.references :user, null: false, foreign_key: true, type: :bigint
      t.boolean :used, default: false, null: false
      t.datetime :expires_at, null: false

      t.timestamps
    end
    add_index :tokens, :id, unique: true
  end
end
