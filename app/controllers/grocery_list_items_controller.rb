class GroceryListItemsController < ApplicationController
  before_action :authenticate_user!

  def create
    item = Item.find(params[:item_id])
    grocery_list_item = current_user.family.grocery_list_items.find_or_initialize_by(item: item)
    inventory_item = current_user.inventory_items.find_by(item: item)
    quantity_step = if params[:quantity].present?
                      BigDecimal(params[:quantity])
                    else
                      inventory_item&.custom_unit_step || 1
                    end
    grocery_list_item.quantity += quantity_step
    grocery_list_item.save

    prepare_collections
    @item = item
    flash.now[:notice] = "#{item.name} adicionado à lista de compras"

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to grocery_list_path }
    end
  end

  def update
    grocery_list_item = current_user.family.grocery_list_items.find(params[:id])
    new_quantity = BigDecimal(params[:quantity])
    grocery_list_item.update(quantity: new_quantity) if new_quantity.positive?
    prepare_collections
    flash.now[:notice] = "Quantidade atualizada para #{grocery_list_item.item.name}"

    respond_to do |format|
      format.html { redirect_to grocery_list_path }
      format.turbo_stream
    end
  end

  def destroy
    grocery_list_item = current_user.family.grocery_list_items.find(params[:id])
    grocery_list_item.destroy
    prepare_collections
    flash.now[:notice] = "#{grocery_list_item.item.name} removido da lista"

    respond_to do |format|
      format.html { redirect_to grocery_list_path }
      format.turbo_stream
    end
  end

  private

  def prepare_collections
    family = current_user.family
    @grocery_list_items = family.grocery_list_items.includes(:item)
    existing_item_ids = @grocery_list_items.map(&:item_id)
    @inventory_lookup = current_user.inventory_items.index_by(&:item_id)
    @suggested_inventory_items = current_user.inventory_items
                                                    .includes(item: :category)
                                                    .suggested_for_restock
                                                    .where.not(item_id: existing_item_ids)
  end
end
