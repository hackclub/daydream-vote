class Vote < ApplicationRecord
  belongs_to :user
  belongs_to :project

  has_one :event, through: :project
end
