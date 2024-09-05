class UserItemsController < ApplicationController
  before_action :authenticate_user!

  def create
    item = Item.find(params[:item_id])
    user_item = current_user.user_items.find_or_initialize_by(item: item)
    user_item.quantity += 1
    user_item.save

    respond_to do |format|
      format.html { redirect_to root_path }
      format.turbo_stream
    end
  end

  def update
    user_item = current_user.user_items.find(params[:id])
    new_quantity = [user_item.quantity + params[:quantity].to_i, 0].max
    user_item.update(quantity: new_quantity)

    respond_to do |format|
      format.html { redirect_to root_path }
      format.turbo_stream
    end
  end

  def destroy
    user_item = current_user.user_items.find(params[:id])
    user_item.destroy

    respond_to do |format|
      format.html { redirect_to root_path }
      format.turbo_stream
    end
  end
end
