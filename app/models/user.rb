class User < ApplicationRecord
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  has_many :tokens, dependent: :destroy
  has_one :profile_datum, dependent: :destroy
  has_many :projects, dependent: :destroy
  
  before_validation :normalize_email
  
  private
  
  def normalize_email
    self.email = email&.downcase&.strip
  end
end
