class InventoryItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_inventory_item, only: %i[update destroy]

  def create
    item = Item.find(params[:item_id])
    @inventory_item = current_user.inventory_items.find_or_create_by!(item: item)
    increment_by = parse_amount(params[:quantity]) || default_step
    @inventory_item.increment!(increment_by)
    flash.now[:notice] = "Estoque atualizado"

    respond_to do |format|
      format.html { redirect_to root_path }
      format.turbo_stream
    end
  end

  def update
    if params[:inventory_item].present?
      if @inventory_item.update(target_params)
        flash.now[:notice] = "Metas atualizadas para #{ @inventory_item.item.name }"
      else
        flash.now[:alert] = @inventory_item.errors.full_messages.to_sentence
      end
      @inventory_item.reload
    else
      delta = parse_amount(params[:quantity]) || default_step
      if delta.positive?
        @inventory_item.increment!(delta)
      else
        @inventory_item.decrement!(delta.abs)
      end
      flash.now[:notice] = "Estoque ajustado"
      @inventory_item.reload
    end

    respond_to do |format|
      format.html { redirect_to root_path }
      format.turbo_stream
    end
  end

  def destroy
    @inventory_item.update(quantity: 0)
    flash.now[:notice] = "Estoque zerado"

    respond_to do |format|
      format.html { redirect_to root_path }
      format.turbo_stream
    end
  end

  private

  def set_inventory_item
    @inventory_item = current_user.inventory_items.find(params[:id])
  end

  def parse_amount(value)
    return unless value.present?

    BigDecimal(value.to_s)
  rescue ArgumentError
    nil
  end

  def default_step
    step = @inventory_item&.custom_unit_step
    step.present? ? BigDecimal(step.to_s) : BigDecimal(1)
  end

  def target_params
    permitted = params.require(:inventory_item).permit(:minimum_quantity, :critical_quantity, :expires_at)
    %w[minimum_quantity critical_quantity].each do |key|
      value = permitted[key]
      permitted[key] = value.present? ? parse_amount(value) : nil
    end
    permitted
  end
end
