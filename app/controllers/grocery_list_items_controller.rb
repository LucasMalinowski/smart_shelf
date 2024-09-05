class GroceryListItemsController < ApplicationController
  before_action :authenticate_user!

  def create
    item = Item.find(params[:item_id])
    grocery_list_item = current_user.grocery_list_items.find_or_initialize_by(item: item)
    grocery_list_item.quantity += 1
    grocery_list_item.save

    respond_to do |format|
      format.html { redirect_to grocery_list_path }
      format.turbo_stream
    end
  end

  def update
    grocery_list_item = current_user.grocery_list_items.find(params[:id])
    new_quantity = params[:quantity].to_i
    grocery_list_item.update(quantity: new_quantity) if new_quantity > 0

    respond_to do |format|
      format.html { redirect_to grocery_list_path }
      format.turbo_stream
    end
  end

  def destroy
    grocery_list_item = current_user.grocery_list_items.find(params[:id])
    grocery_list_item.destroy

    respond_to do |format|
      format.html { redirect_to grocery_list_path }
      format.turbo_stream
    end
  end
end
