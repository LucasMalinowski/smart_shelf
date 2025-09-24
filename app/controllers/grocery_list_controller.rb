class GroceryListController < ApplicationController
  before_action :authenticate_user!

  def index
    family = current_user.family
    @grocery_list_items = family.grocery_list_items.includes(:item)
    existing_item_ids = @grocery_list_items.map(&:item_id)
    @suggested_inventory_items = current_user.inventory_items
                                                      .includes(item: :category)
                                                      .suggested_for_restock
                                                      .where.not(item_id: existing_item_ids)
    @inventory_lookup = current_user.inventory_items.index_by(&:item_id)
  end
end
