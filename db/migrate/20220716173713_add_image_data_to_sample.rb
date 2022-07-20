class AddImageDataToSample < ActiveRecord::Migration[7.0]
  def change
    add_column :samples, :image_data, :text
  end
end
