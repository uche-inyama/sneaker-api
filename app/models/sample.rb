class Sample < ApplicationRecord
  include ImageUploader::Attachment(:image)
  belongs_to :product

  # has_many_attached :images
end
