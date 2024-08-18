class Document < ApplicationRecord
  belongs_to :user
  has_one_attached :file
  has_many :products, dependent: :destroy
  has_many :taxes, dependent: :destroy
end