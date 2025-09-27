class CreatorPositionInvite < ApplicationRecord
  belongs_to :project
  belongs_to :invited_by, class_name: 'User'
  
  before_create :generate_token, :set_expiration
  
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :email, uniqueness: { scope: :project_id }
  
  def expired?
    expires_at < Time.current
  end
  
  def valid_for_acceptance?
    !expired?
  end
  
  def accept!(user)
    return false if expired?
    
    ActiveRecord::Base.transaction do
      project.creator_positions.create!(user: user, role: :collaborator)
      destroy!
    end
    true
  end
  
  private
  
  def generate_token
    self.token = SecureRandom.uuid
  end
  
  def set_expiration
    self.expires_at = 7.days.from_now
  end
end
