class ChangePublisherIdNullableOnCharacters < ActiveRecord::Migration[7.2]
  def change
    change_column_null :characters, :publisher_id, true
  end
end
