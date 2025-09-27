class User < ApplicationRecord
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  has_many :tokens, dependent: :destroy
  has_one :profile_datum, dependent: :destroy
  has_many :creator_positions, dependent: :destroy
  has_many :projects, through: :creator_positions
  has_many :organizer_positions, dependent: :destroy
  has_many :organized_events, through: :organizer_positions, source: :event
  has_many :votes, dependent: :destroy
  has_many :voted_projects, through: :votes, source: :project

  before_validation :normalize_email

  def last_unlocked_step
    if projects.all? { |p| p.submitted? } && projects.any?
      :vote
    elsif projects.any? { |p| p.draft? }
      :review
    elsif projects.any? { |p| p.can_invite_collaborators? }
      :invite_team
    elsif projects.any?
      :invite_team  # If you have projects, you can at least try to invite team
    elsif profile_datum.present?
      :project_info
    else
      :your_info
    end
  end

  private

  def normalize_email
    self.email = email&.downcase&.strip
  end
end
