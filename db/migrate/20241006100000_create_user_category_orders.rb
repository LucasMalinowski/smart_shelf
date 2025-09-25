class CreateUserCategoryOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :user_category_orders do |t|
      t.references :user, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.integer :position, null: false

      t.timestamps
    end

    add_index :user_category_orders, [:user_id, :category_id], unique: true
    add_index :user_category_orders, [:user_id, :position]
  end
end
