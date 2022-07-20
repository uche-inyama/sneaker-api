class ProductSerializer < ActiveModel::Serializer
  attributes :id, :name, :marketing_statement, :product_price, :product_discount

  has_many :samples
end
