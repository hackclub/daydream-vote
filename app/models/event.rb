class Event < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  has_many :projects, foreign_key: :attending_event_id, dependent: :restrict_with_error
end
