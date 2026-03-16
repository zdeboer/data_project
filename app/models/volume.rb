class Volume < ApplicationRecord
  belongs_to :publisher
  has_many :issues, dependent: :destroy

  validates :name, presence: true
  validates :cv_id, uniqueness: true, allow_nil: true
end
