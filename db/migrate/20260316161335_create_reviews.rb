class CreateReviews < ActiveRecord::Migration[7.2]
  def change
    create_table :reviews do |t|
      t.references :issue, null: false, foreign_key: true
      t.string :reviewer_name
      t.integer :rating
      t.text :body

      t.timestamps
    end
  end
end
