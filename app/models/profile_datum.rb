class ProfileDatum < ApplicationRecord
  belongs_to :user
  
  encrypts :first_name
  encrypts :last_name
  encrypts :dob
  encrypts :address_line_1
  encrypts :address_line_2
  encrypts :address_city
  encrypts :address_state
  encrypts :address_zip_code
  encrypts :address_country
  

  
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :dob, presence: true
  validates :address_line_1, presence: true
  validates :address_city, presence: true
  validates :address_state, presence: true
  validates :address_zip_code, presence: true
  validates :address_country, presence: true

end
