class User < ApplicationRecord
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  has_many :tokens, dependent: :destroy
  has_one :profile_datum, dependent: :destroy
  has_many :creator_positions, dependent: :destroy
  has_many :projects, through: :creator_positions
  
  before_validation :normalize_email
  
  private
  
  def normalize_email
    self.email = email&.downcase&.strip
  end
end
