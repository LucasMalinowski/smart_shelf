class Category < ApplicationRecord
  has_many :items
  has_one :category_measurement_unit, dependent: :destroy
  has_one :measurement_unit, through: :category_measurement_unit
end
