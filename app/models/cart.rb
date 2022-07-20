class Cart < ApplicationRecord
  has_many :orderables, dependent: :destroy
  has_many :products, through: :Orderables
end
