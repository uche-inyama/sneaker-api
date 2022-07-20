class Orderable < ApplicationRecord
  belongs_to :product
  belongs_to :cart
  validates_presence_of :product_id, :cart_id, :quantity, :image
end
