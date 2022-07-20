class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :products do |t|
      t.string :name
      t.string :marketing_statement
      t.decimal :product_price
      t.decimal :product_discount

      t.timestamps
    end
  end
end
