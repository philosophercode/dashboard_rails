class Website < ApplicationRecord
  validates :user_id, presence: true
  belongs_to :user
  belongs_to :category
end
