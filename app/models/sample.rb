class Sample < ApplicationRecord
  include ImageUploader::Attachment(:image)
  belongs_to :product

  validates_presence_of :product_id, :image_data
end
