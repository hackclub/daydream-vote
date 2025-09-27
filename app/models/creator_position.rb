class CreatorPosition < ApplicationRecord
  belongs_to :user
  belongs_to :project
  
  enum :role, {
    owner: 0,
    collaborator: 1
  }
  
  validates :user_id, uniqueness: { scope: :project_id }
  
  def can_invite_to_project?
    owner?
  end
end
