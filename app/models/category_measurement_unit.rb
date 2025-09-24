# frozen_string_literal: true

class CategoryMeasurementUnit < ApplicationRecord
  belongs_to :category
  belongs_to :measurement_unit

  validates :category_id, uniqueness: true
end
