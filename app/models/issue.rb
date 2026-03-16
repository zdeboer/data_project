class Issue < ApplicationRecord
  belongs_to :volume
  has_many :character_issues, dependent: :destroy
  has_many :characters, through: :character_issues
  has_many :reviews, dependent: :destroy

  validates :issue_number, presence: true
  validates :cv_id, uniqueness: true, allow_nil: true
end
