class Character < ApplicationRecord
  belongs_to :publisher, optional: true
  has_many :character_issues, dependent: :destroy
  has_many :issues, through: :character_issues

  validates :name, presence: true
  validates :cv_id, uniqueness: true, allow_nil: true
end
