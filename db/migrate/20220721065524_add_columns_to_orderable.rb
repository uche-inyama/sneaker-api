class AddColumnsToOrderable < ActiveRecord::Migration[7.0]
  def change
    add_column :orderables, :marketing_statement, :text
    add_column :orderables, :product_price, :decimal
    add_column :orderables, :product_discount, :decimal
  end
end
