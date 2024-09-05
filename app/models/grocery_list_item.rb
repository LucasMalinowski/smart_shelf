class GroceryListItem < ApplicationRecord
  belongs_to :user
  belongs_to :item

  validates :quantity, numericality: { greater_than: 0 }
end
