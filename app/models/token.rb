class Token < ApplicationRecord
  belongs_to :user
  
  before_create :generate_uuid
  
  scope :valid, -> { where(used: false).where("expires_at > ?", Time.current) }
  
  def expired?
    expires_at < Time.current
  end
  
  def valid_for_login?
    !used && !expired?
  end
  
  def mark_as_used!
    update!(used: true)
  end
  
  private
  
  def generate_uuid
    self.id = SecureRandom.uuid
  end
end
