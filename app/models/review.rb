class Review < ApplicationRecord
  belongs_to :issue

  validates :reviewer_name, presence: true
  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :body, presence: true
end
