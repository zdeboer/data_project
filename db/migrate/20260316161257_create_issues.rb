class CreateIssues < ActiveRecord::Migration[7.2]
  def change
    create_table :issues do |t|
      t.string :name
      t.string :issue_number
      t.date :cover_date
      t.string :image_url
      t.text :description
      t.integer :cv_id
      t.references :volume, null: false, foreign_key: true

      t.timestamps
    end
  end
end
