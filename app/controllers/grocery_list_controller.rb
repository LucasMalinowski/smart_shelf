class GroceryListController < ApplicationController
  before_action :authenticate_user!

  def index
    @grocery_list_items = current_user.grocery_list_items.includes(:item)
  end
end
