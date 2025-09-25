class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :family

  has_many :inventory_items, through: :family
  has_many :grocery_list_items, through: :family
  has_many :family_notifications, through: :family
  has_many :category_orders, -> { order(:position) }, class_name: 'UserCategoryOrder', dependent: :destroy
  has_many :ordered_categories, through: :category_orders, source: :category
  has_many :hidden_inventory_items, dependent: :destroy

  before_validation :ensure_family, on: :create

  def category_sequence(all_categories = Category.order(:name))
    user_order = ordered_categories.to_a
    remaining = (all_categories - user_order).sort_by(&:name)
    user_order + remaining
  end

  def hidden_inventory_item_ids
    hidden_inventory_items.pluck(:inventory_item_id)
  end

  private

  def ensure_family
    return if family.present?

    self.family = Family.new(name: default_family_name)
  end

  def default_family_name
    local_part = email.to_s.split("@").first.presence || "Família"
    "Família #{local_part.titleize}"
  end
end
