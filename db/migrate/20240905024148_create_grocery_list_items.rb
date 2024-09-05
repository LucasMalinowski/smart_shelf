class CreateGroceryListItems < ActiveRecord::Migration[7.1]
  def change
    create_table :grocery_list_items do |t|
      t.references :user, null: false, foreign_key: true
      t.references :item, null: false, foreign_key: true
      t.integer :quantity, default: 0

      t.timestamps
    end
  end
end
