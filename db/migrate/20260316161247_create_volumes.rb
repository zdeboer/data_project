class CreateVolumes < ActiveRecord::Migration[7.2]
  def change
    create_table :volumes do |t|
      t.string :name
      t.integer :start_year
      t.string :image_url
      t.integer :cv_id
      t.references :publisher, null: false, foreign_key: true

      t.timestamps
    end
  end
end
