# frozen_string_literal: true

class CreateInventoryItems < ActiveRecord::Migration[7.1]
  class MigrationInventoryItem < ActiveRecord::Base
    self.table_name = "inventory_items"
  end

  class MigrationUser < ActiveRecord::Base
    self.table_name = "users"
  end

  class MigrationMeasurementUnit < ActiveRecord::Base
    self.table_name = "measurement_units"
  end

  def up
    create_table :measurement_units do |t|
      t.string :name, null: false
      t.string :short_name
      t.string :unit_type, null: false, default: "unit"
      t.decimal :step, precision: 8, scale: 3, null: false, default: 1
      t.boolean :fractional, null: false, default: false
      t.timestamps
    end

    add_index :measurement_units, :name, unique: true

    create_table :category_measurement_units do |t|
      t.references :category, null: false, foreign_key: true
      t.references :measurement_unit, null: false, foreign_key: true
      t.timestamps
    end

    add_reference :items, :default_measurement_unit, foreign_key: { to_table: :measurement_units }

    rename_table :user_items, :inventory_items

    add_reference :inventory_items, :family, foreign_key: true
    add_reference :inventory_items, :measurement_unit, foreign_key: true
    add_column :inventory_items, :custom_unit_name, :string
    add_column :inventory_items, :custom_unit_step, :decimal, precision: 8, scale: 3, default: 1, null: false
    add_column :inventory_items, :unit_precision, :integer, default: 0, null: false
    add_column :inventory_items, :minimum_quantity, :decimal, precision: 12, scale: 3
    add_column :inventory_items, :critical_quantity, :decimal, precision: 12, scale: 3
    add_column :inventory_items, :expires_at, :datetime
    add_column :inventory_items, :last_restocked_at, :datetime
    add_column :inventory_items, :low_stock_notified_at, :datetime
    add_column :inventory_items, :critical_stock_notified_at, :datetime
    add_column :inventory_items, :expiration_notified_at, :datetime
    add_column :inventory_items, :metadata, :jsonb, default: {}, null: false
    change_column :inventory_items, :quantity, :decimal, precision: 12, scale: 3, default: 0, null: false

    add_index :inventory_items, [:family_id, :item_id], unique: true

    MigrationMeasurementUnit.reset_column_information
    seed_units

    MigrationInventoryItem.reset_column_information
    MigrationUser.reset_column_information

    MigrationInventoryItem.find_each do |inventory_item|
      next if inventory_item.family_id.present?

      user = MigrationUser.find_by(id: inventory_item[:user_id])
      next unless user

      inventory_item.update_columns(family_id: user.family_id)
    end

    change_column_null :inventory_items, :family_id, false

    remove_reference :inventory_items, :user, foreign_key: true
  end

  def down
    add_reference :inventory_items, :user, foreign_key: true

    MigrationInventoryItem.reset_column_information
    MigrationUser.reset_column_information

    MigrationInventoryItem.find_each do |inventory_item|
      user = MigrationUser.find_by(family_id: inventory_item.family_id)
      inventory_item.update_columns(user_id: user.id) if user
    end

    remove_index :inventory_items, column: [:family_id, :item_id]

    change_column :inventory_items, :quantity, :integer
    remove_column :inventory_items, :metadata
    remove_column :inventory_items, :expiration_notified_at
    remove_column :inventory_items, :critical_stock_notified_at
    remove_column :inventory_items, :low_stock_notified_at
    remove_column :inventory_items, :last_restocked_at
    remove_column :inventory_items, :expires_at
    remove_column :inventory_items, :critical_quantity
    remove_column :inventory_items, :minimum_quantity
    remove_column :inventory_items, :unit_precision
    remove_column :inventory_items, :custom_unit_step
    remove_column :inventory_items, :custom_unit_name
    remove_reference :inventory_items, :measurement_unit, foreign_key: true
    remove_reference :inventory_items, :family, foreign_key: true

    rename_table :inventory_items, :user_items

    remove_reference :items, :default_measurement_unit, foreign_key: true

    drop_table :category_measurement_units
    drop_table :measurement_units
  end

  private

  def seed_units
    units = [
      { name: "Unidade", short_name: "uni", unit_type: "unit", step: 1, fractional: false },
      { name: "Quilograma", short_name: "kg", unit_type: "weight", step: 0.1, fractional: true },
      { name: "Grama", short_name: "g", unit_type: "weight", step: 10, fractional: true },
      { name: "Litro", short_name: "L", unit_type: "volume", step: 0.1, fractional: true },
      { name: "Mililitro", short_name: "ml", unit_type: "volume", step: 50, fractional: true },
      { name: "Xícara", short_name: "cup", unit_type: "volume", step: 0.25, fractional: true },
      { name: "Colher de sopa", short_name: "tbsp", unit_type: "volume", step: 0.5, fractional: true }
    ]

    units.each do |attrs|
      MigrationMeasurementUnit.find_or_create_by!(name: attrs[:name]) do |unit|
        unit.assign_attributes(attrs)
      end
    end
  end
end
