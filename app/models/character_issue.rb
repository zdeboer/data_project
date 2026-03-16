class CharacterIssue < ApplicationRecord
  belongs_to :character
  belongs_to :issue

  validates :character_id, uniqueness: { scope: :issue_id }
end
