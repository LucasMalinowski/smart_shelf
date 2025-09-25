class UserCategoryOrder < ApplicationRecord
  belongs_to :user
  belongs_to :category

  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :category_id, uniqueness: { scope: :user_id }
end
