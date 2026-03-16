class CreateCharacters < ActiveRecord::Migration[7.2]
  def change
    create_table :characters do |t|
      t.string :name
      t.string :real_name
      t.text :deck
      t.string :image_url
      t.integer :cv_id
      t.references :publisher, null: false, foreign_key: true

      t.timestamps
    end
  end
end
