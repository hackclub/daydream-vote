class Project < ApplicationRecord
  has_many :creator_positions, dependent: :destroy
  has_many :users, through: :creator_positions
  has_one :precheck, dependent: :destroy
  has_many :creator_position_invites, dependent: :destroy
  has_one_attached :image

  validates :title, presence: true
  validates :description, presence: true
  validates :itchio_url, presence: true
  validates :repo_url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be a valid URL" }
  validate :itchio_url_is_playable
  validate :repo_url_is_accessible

  include AASM

  aasm timestamps: true do
    state :draft, initial: true
    state :submitted

    event :mark_submitted do
      transitions from: :draft, to: :submitted
    end
  end

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

  def has_pending_invites?
    creator_position_invites.where("expires_at > ?", Time.current).exists?
  end

  private

  def itchio_url_is_playable
    return if itchio_url.blank? # Let presence validation handle blank URLs

    unless ItchioChecker.playable?(itchio_url)
      errors.add(:itchio_url, "does not appear to have a play button or may not be playable in browser")
    end
  end

  def repo_url_is_accessible
    return if repo_url.blank? # Let presence validation handle blank URLs

    unless GitRepoChecker.accessible?(repo_url)
      errors.add(:repo_url, "is not accessible or does not exist")
    end
  end
end
