class CreateProfileData < ActiveRecord::Migration[8.0]
  def change
    create_table :profile_data do |t|
      t.references :user, null: false, foreign_key: true
      t.string :first_name
      t.string :last_name
      t.date :dob
      t.string :address_line_1
      t.string :address_line_2
      t.string :address_city
      t.string :address_state
      t.string :address_zip_code
      t.string :address_country

      t.timestamps
    end
  end
end
