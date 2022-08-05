require 'rails_helper'

RSpec.describe Orderable, type: :model do
  it "validates the presence of orderable attributes" do
    cart = Cart.create()
    product = Product.create( name: "Nike air", marketing_statement: "lorem ipsum",
                            product_price: 1000, product_discount: 20)
    
    expect(Orderable.new()).not_to be_valid
    expect(Orderable.new(
      product_id: product.id,
      cart_id: cart.id,
      quantity: 2,
      image: 'image_url',
      marketing_statement: 'lorem ipsum',
      product_price: 1000,
      product_discount: 20
    )).to be_valid
  end
end
