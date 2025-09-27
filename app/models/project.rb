class Project < ApplicationRecord
  has_many :creator_positions, dependent: :destroy
  has_many :users, through: :creator_positions
  has_many :votes, dependent: :destroy
  has_many :voters, through: :votes, source: :user
  has_one :precheck, dependent: :destroy
  has_many :creator_position_invites, dependent: :destroy
  has_one_attached :image

  belongs_to :attending_event, class_name: "Event"

  validates :title, presence: true
  validates :description, presence: true
  validates :itchio_url, presence: true
  validates :repo_url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be a valid URL" }
  validate :itchio_url_is_playable
  validate :repo_url_is_accessible
  validate :image_is_valid_type
  validate :image_is_valid_size

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
  
  scope :visible, -> { where(hidden: false) }
  scope :hidden, -> { where(hidden: true) }
  
  def hide!
    update!(hidden: true)
  end
  
  def unhide!
    update!(hidden: false)
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

  def image_is_valid_type
    return unless image.attached?

    allowed_types = [ "image/png", "image/jpg", "image/jpeg", "image/gif", "image/webp" ]
    unless allowed_types.include?(image.content_type)
      errors.add(:image, "must be an image file (PNG, JPG, JPEG, GIF, or WebP)")
    end
  end

  def image_is_valid_size
    return unless image.attached?

    max_size = 100.megabytes
    if image.byte_size > max_size
      errors.add(:image, "is too large (maximum is #{max_size / 1.megabyte}MB)")
    end
  end
end
