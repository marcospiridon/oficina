class Workshop < ApplicationRecord
  has_many :users
  has_many :vehicles

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
end
