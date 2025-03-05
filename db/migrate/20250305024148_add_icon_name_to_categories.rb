class AddIconNameToCategories < ActiveRecord::Migration[7.1]
  def change
    add_column :categories, :icon_name, :string
  end
end
