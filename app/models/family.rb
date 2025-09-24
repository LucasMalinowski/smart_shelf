# frozen_string_literal: true

class Family < ApplicationRecord
  has_many :users, dependent: :nullify
  has_many :inventory_items, dependent: :destroy
  has_many :family_notifications, dependent: :destroy
  has_many :family_invitations, dependent: :destroy
  has_many :grocery_list_items, dependent: :destroy

  before_validation :ensure_slug_and_invite_code
  after_create :bootstrap_inventory

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :invite_code, presence: true, uniqueness: true
  validates :unit_system, inclusion: { in: %w[metric imperial custom] }

  def to_param
    slug
  end

  def default_measurement_unit_for(category)
    return unless category

    category_measurement = category.measurement_unit || MeasurementUnit.default_unit
    category_measurement
  end

  private

  def ensure_slug_and_invite_code
    self.name = name.presence || "Família"
    self.slug = generate_slug if slug.blank?
    self.invite_code = SecureRandom.hex(10) if invite_code.blank?
    self.unit_system = unit_system.presence || "metric"
  end

  def generate_slug
    base = name.parameterize
    return SecureRandom.hex(3) if base.blank?

    candidate = base
    suffix = 2
    while Family.exists?(slug: candidate)
      candidate = "#{base}-#{suffix}"
      suffix += 1
    end
    candidate
  end

  def bootstrap_inventory
    items = Item.includes(:category)
    items.find_each do |item|
      unit = item.default_measurement_unit || default_measurement_unit_for(item.category)
      inventory_items.find_or_create_by!(item: item) do |inventory|
        inventory.measurement_unit = unit
        inventory.custom_unit_name = unit&.label
        inventory.custom_unit_step = unit&.step || 1
        inventory.unit_precision = unit&.fractional? ? 2 : 0
        inventory.quantity = 0
      end
    end
  end
end
