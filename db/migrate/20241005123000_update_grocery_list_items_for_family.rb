# frozen_string_literal: true

class UpdateGroceryListItemsForFamily < ActiveRecord::Migration[7.1]
  class MigrationGroceryListItem < ActiveRecord::Base
    self.table_name = "grocery_list_items"
  end

  class MigrationUser < ActiveRecord::Base
    self.table_name = "users"
  end

  def up
    add_reference :grocery_list_items, :family, foreign_key: true

    MigrationGroceryListItem.reset_column_information
    MigrationUser.reset_column_information

    MigrationGroceryListItem.find_each do |record|
      user = MigrationUser.find_by(id: record[:user_id])
      record.update_columns(family_id: user&.family_id)
    end

    change_column_null :grocery_list_items, :family_id, false
    remove_reference :grocery_list_items, :user, foreign_key: true
  end

  def down
    add_reference :grocery_list_items, :user, foreign_key: true

    MigrationGroceryListItem.reset_column_information
    MigrationUser.reset_column_information

    MigrationGroceryListItem.find_each do |record|
      user = MigrationUser.find_by(family_id: record.family_id)
      record.update_columns(user_id: user&.id)
    end

    change_column_null :grocery_list_items, :user_id, false
    remove_reference :grocery_list_items, :family, foreign_key: true
  end
end
