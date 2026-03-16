class CreatePublishers < ActiveRecord::Migration[7.2]
  def change
    create_table :publishers do |t|
      t.string :name
      t.text :deck
      t.string :image_url
      t.integer :cv_id

      t.timestamps
    end
  end
end
