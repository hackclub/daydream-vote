class Event < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  has_many :projects, foreign_key: :attending_event_id, dependent: :restrict_with_error
  has_many :organizer_positions, dependent: :destroy
  has_many :organizers, through: :organizer_positions, source: :user

  def to_param
    name
  end
end
