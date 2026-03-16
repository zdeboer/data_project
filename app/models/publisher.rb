class Publisher < ApplicationRecord
  has_many :volumes, dependent: :destroy
  has_many :characters, dependent: :nullify

  validates :name, presence: true
  validates :cv_id, uniqueness: true, allow_nil: true
end
