class AddImageToOrderable < ActiveRecord::Migration[7.0]
  def change
    add_column :orderables, :image, :string
  end
end
