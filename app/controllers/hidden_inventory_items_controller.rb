class HiddenInventoryItemsController < ApplicationController
  include ActionView::RecordIdentifier
  before_action :authenticate_user!

  def create
    inventory_item = current_user.inventory_items.find(params.require(:inventory_item_id))
    hidden_item = current_user.hidden_inventory_items.find_or_create_by!(inventory_item: inventory_item)

    respond_to do |format|
      format.turbo_stream do
        flash.now[:notice] = "#{inventory_item.item.name} ocultado."
        render turbo_stream: hide_streams(inventory_item)
      end
      format.html do
        redirect_back fallback_location: items_path, notice: "#{inventory_item.item.name} ocultado."
      end
    end
  end

  def destroy
    hidden_item = current_user.hidden_inventory_items.find(params[:id])
    inventory_item = hidden_item.inventory_item
    hidden_item.destroy

    respond_to do |format|
      format.turbo_stream do
        flash.now[:notice] = "#{inventory_item.item.name} restaurado."
        render turbo_stream: [
          turbo_stream.remove(dom_id(hidden_item)),
          turbo_stream.replace('flash-messages', partial: 'shared/flash')
        ]
      end
      format.html do
        redirect_back fallback_location: settings_path, notice: "#{inventory_item.item.name} restaurado."
      end
    end
  end

  private

  def hide_streams(inventory_item)
    category = inventory_item.item.category
    streams = []

    streams << turbo_stream.remove(dom_id(inventory_item))
    unless visible_items_in_category?(category)
      streams << turbo_stream.remove(dom_id(category, :section))
    end

    streams << turbo_stream.replace('flash-messages', partial: 'shared/flash')
    streams
  end

  def visible_items_in_category?(category)
    current_user.inventory_items
                .joins(:item)
                .where(items: { category_id: category.id })
                .where.not(id: HiddenInventoryItem.where(user: current_user).select(:inventory_item_id))
                .exists?
  end
end
