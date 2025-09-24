class ItemsController < ApplicationController
  before_action :authenticate_user!

  ITEMS_PER_PAGE = 30

  def index
    @categories = Category.order(:name)
    scope = current_user.inventory_items.includes(item: [:category, :default_measurement_unit], measurement_unit: [])

    @selected_category = params[:category_id].presence
    if @selected_category.present? && @selected_category != 'all'
      scope = scope.joins(:item).where(items: { category_id: @selected_category })
    else
      @selected_category = 'all'
    end

    scope = scope.joins(item: :category)

    if params[:sort_by].present?
      direction = params[:sort_direction] == 'desc' ? 'desc' : 'asc'
      scope = scope.order("#{params[:sort_by]} #{direction}")
    else
      scope = scope.order('categories.name ASC, items.name ASC')
    end

    category_ids = scope.unscope(:order).distinct.pluck('categories.id')
    @available_categories = @categories.select { |category| category_ids.include?(category.id) }

    @page = params.fetch(:page, 1).to_i
    @page = 1 if @page < 1

    @total_count = scope.count
    @inventory_scope = scope
    @inventory_items = scope.limit(ITEMS_PER_PAGE).offset((@page - 1) * ITEMS_PER_PAGE)
    grouped_items = @inventory_items.group_by { |inventory| inventory.item.category }
    order_source = if @selected_category == 'all'
                     @available_categories
                   else
                     @available_categories.select { |category| category.id.to_s == @selected_category }
                   end
    @ordered_categories = order_source
    @inventory_items_by_category = {}
    order_source.each do |category|
      items = grouped_items[category]
      next if items.blank?

      @inventory_items_by_category[category] = items
    end
    @loaded_count = [@page * ITEMS_PER_PAGE, @total_count].min

    @has_more = scope.offset(@page * ITEMS_PER_PAGE).limit(1).exists?
    @next_page = @page + 1 if @has_more

    @loaded_category_ids = []
    if @page > 1
      @loaded_category_ids = scope.limit((@page - 1) * ITEMS_PER_PAGE).pluck('categories.id').uniq
    end

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
end
