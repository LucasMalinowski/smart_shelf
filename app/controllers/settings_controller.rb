class SettingsController < ApplicationController
  helper ItemsHelper
  before_action :authenticate_user!

  def show
    @ordered_categories = current_user.category_sequence
    @hidden_inventory_items = current_user.hidden_inventory_items.includes(inventory_item: [:item])
  end

  def category_order
    category_ids = permitted_category_ids

    ActiveRecord::Base.transaction do
      current_user.category_orders.where.not(category_id: category_ids).delete_all

      category_ids.each_with_index do |category_id, index|
        record = current_user.category_orders.find_or_initialize_by(category_id: category_id)
        record.position = index
        record.save!
      end
    end

    respond_to do |format|
      format.turbo_stream do
        flash.now[:notice] = 'Ordem de categorias atualizada.'
        render turbo_stream: turbo_stream.replace('flash-messages', partial: 'shared/flash')
      end
      format.html { redirect_to settings_path, notice: 'Ordem de categorias atualizada.' }
    end
  rescue ActiveRecord::RecordInvalid
    respond_to do |format|
      format.turbo_stream do
        flash.now[:alert] = 'Não foi possível salvar a nova ordem.'
        render turbo_stream: turbo_stream.replace('flash-messages', partial: 'shared/flash')
      end
      format.html { redirect_to settings_path, alert: 'Não foi possível salvar a nova ordem.' }
    end
  end

  private

  def permitted_category_ids
    ids = params[:category_order].to_s.split(',').map(&:strip).reject(&:blank?).map(&:to_i)
    return [] if ids.empty?

    valid_ids = Category.where(id: ids).pluck(:id)
    ids.select { |id| valid_ids.include?(id) }
  end
end
