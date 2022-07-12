# == Schema Information
#
# Table name: products
#
#  id                  :bigint           not null, primary key
#  name                :string
#  company_id          :bigint           not null
#  marketing_statement :string
#  product_price       :decimal(, )
#  product_discount    :decimal(, )
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
class Product < ApplicationRecord
  belongs_to :company
  validates_presence_of :name, :company_id, :marketing_statement, 
  :product_price, :product_discount
end
