class Item < ApplicationRecord
  belongs_to :category
  has_many :user_items
end
