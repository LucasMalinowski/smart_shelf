# frozen_string_literal: true

class CreateFamilyNotifications < ActiveRecord::Migration[7.1]
  def change
    create_table :family_notifications do |t|
      t.references :family, null: false, foreign_key: true
      t.references :inventory_item, foreign_key: true
      t.string :kind, null: false
      t.string :title, null: false
      t.text :body
      t.integer :status, null: false, default: 0
      t.jsonb :payload, null: false, default: {}
      t.datetime :triggered_at, null: false
      t.datetime :read_at
      t.references :read_by, foreign_key: { to_table: :users }
      t.timestamps
    end

    add_index :family_notifications, [:family_id, :status]
    add_index :family_notifications, :triggered_at
  end
end
