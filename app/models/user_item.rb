class UserItem < ApplicationRecord
  belongs_to :user
  belongs_to :item

  validates :quantity, numericality: { greater_than_or_equal_to: 0 }

  scope :by_category, ->(category_id) { joins(item: :category).where(categories: { id: category_id }) }
end
