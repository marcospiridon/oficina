class Vehicle < ApplicationRecord
  belongs_to :workshop

  has_many_attached :photos
  has_many_attached :documents

  validates :license_plate, presence: true, uniqueness: { scope: :workshop_id, case_sensitive: false }

  # Normalize license plate to uppercase
  before_save :normalize_plate

  private

  def normalize_plate
    self.license_plate = license_plate.upcase.gsub(/\s+/, "") if license_plate.present?
  end
end
