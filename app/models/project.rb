class Project < ApplicationRecord
  has_many :creator_positions, dependent: :destroy
  has_many :users, through: :creator_positions
  has_one :precheck, dependent: :destroy
  has_many :creator_position_invites, dependent: :destroy
  has_one_attached :image
  
  validates :title, presence: true
  validates :description, presence: true
  
  after_create :create_precheck, :run_precheck
  
  def can_invite_collaborators?
    precheck&.passed?
  end
  
  def user_can_invite?(user)
    can_invite_collaborators? && 
      creator_positions.joins(:user).where(users: { id: user.id }, role: :owner).exists?
  end
  
  def owner
    creator_positions.joins(:user).find_by(role: :owner)&.user
  end
  
  private
  
  def create_precheck
    build_precheck.save!
  end
  
  def run_precheck
    precheck.run_check!
  end
end
