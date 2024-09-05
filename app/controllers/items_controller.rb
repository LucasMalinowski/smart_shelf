class ItemsController < ApplicationController
  before_action :authenticate_user!

  def index
    @categories = Category.all
    @user_items = current_user.user_items.includes(item: :category)

    if params[:category_id].present?
      @user_items = @user_items.by_category(params[:category_id])
    end

    if params[:sort_by].present?
      direction = params[:sort_direction] == 'desc' ? 'desc' : 'asc'
      @user_items = @user_items.order("#{params[:sort_by]} #{direction}")
    end
  end
end
