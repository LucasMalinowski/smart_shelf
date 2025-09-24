# frozen_string_literal: true

class MeasurementUnit < ApplicationRecord
  UNIT_TYPES = %w[unit weight volume length area].freeze

  has_many :inventory_items
  has_many :category_measurement_units

  validates :name, presence: true, uniqueness: true
  validates :unit_type, presence: true, inclusion: { in: UNIT_TYPES }
  validates :step, numericality: { greater_than: 0 }

  scope :fractions, -> { where(fractional: true) }
  scope :by_type, ->(unit_type) { where(unit_type: unit_type) }

  def self.default_unit
    find_by(name: "Unidade")
  end

  def label
    short_name.presence || name
  end

  def fractional?
    fractional
  end
end
