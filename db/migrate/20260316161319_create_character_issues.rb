class CreateCharacterIssues < ActiveRecord::Migration[7.2]
  def change
    create_table :character_issues do |t|
      t.references :character, null: false, foreign_key: true
      t.references :issue, null: false, foreign_key: true

      t.timestamps
    end
  end
end
