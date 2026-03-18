class AddCharactersSeededToIssues < ActiveRecord::Migration[7.2]
  def change
    add_column :issues, :characters_seeded, :boolean
  end
end
