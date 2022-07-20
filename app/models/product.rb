# == Schema Information
#
# Table name: products
#
#  id                  :bigint           not null, primary key
#  name                :string
#  marketing_statement :string
#  product_price       :decimal(, )
#  product_discount    :decimal(, )
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
class Product < ApplicationRecord
  has_many :samples, dependent: :destroy
  has_many :Orderables
  has_many :carts, through: :OrderablesS

  validates_presence_of :name, :marketing_statement, 
  :product_price, :product_discount
end
