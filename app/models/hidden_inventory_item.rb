class HiddenInventoryItem < ApplicationRecord
  belongs_to :user
  belongs_to :inventory_item

  validates :inventory_item_id, uniqueness: { scope: :user_id }

  scope :for_user, ->(user) { where(user: user) }
end
