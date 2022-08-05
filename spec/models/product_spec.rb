require 'rails_helper'

# name                :string
#  marketing_statement :string
#  product_price       :decimal(, )
#  product_discount    :decimal(, )
#  created_at          :datetime         not null
#  updated_at  

RSpec.describe Product, type: :model do
  it "validates the attributes of product" do
    expect(Product.new()).not_to be_valid
    expect(Product.new(
      name: "Nike air",
      marketing_statement: "lorem ipsum",
      product_price: 1000,
      product_discount: 20
      )).to be_valid
  end
end
