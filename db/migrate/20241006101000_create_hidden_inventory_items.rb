class CreateHiddenInventoryItems < ActiveRecord::Migration[7.1]
  def change
    create_table :hidden_inventory_items do |t|
      t.references :user, null: false, foreign_key: true
      t.references :inventory_item, null: false, foreign_key: true
      t.datetime :hidden_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }

      t.timestamps
    end

    add_index :hidden_inventory_items, [:user_id, :inventory_item_id], unique: true, name: 'index_hidden_items_on_user_and_inventory'
  end
end
