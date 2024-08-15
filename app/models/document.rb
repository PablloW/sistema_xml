class Document < ApplicationRecord
  belongs_to :user
  has_one_attached :file
  has_many :products
  has_many :taxes
end
