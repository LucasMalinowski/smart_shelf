class GroceryListItem < ApplicationRecord
  belongs_to :family
  belongs_to :item

  validates :quantity, numericality: { greater_than: 0 }
  validates :item_id, uniqueness: { scope: :family_id }
end
