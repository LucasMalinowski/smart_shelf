module ItemsHelper
  include ActionView::Helpers::NumberHelper
  CATEGORY_ICON_MAP = {
    "apple-whole" => "🍎",
    "carrot" => "🥕",
    "cheese" => "🧀",
    "bread-slice" => "🍞",
    "fish" => "🐟",
    "drumstick-bite" => "🍗",
    "cookie" => "🍪",
    "bottle-droplet" => "🧴",
    "broom" => "🧹",
    "basket-shopping" => "🛒",
    "seedling" => "🌱",
    "wine-bottle" => "🍷",
    "circle-minus" => "⭕",
    "paw" => "🐾",
    "soap" => "🧼",
    "bottle-water" => "🥤"
  }.freeze

  def category_icon(category)
    CATEGORY_ICON_MAP.fetch(category.icon_name, category.name.to_s.first&.upcase || "📦")
  end

  STATUS_STYLE_MAP = {
    healthy: {
      ring: "ring-primary-200/60 dark:ring-primary-500/30",
      badge: "bg-primary-500/15 text-primary-600 dark:bg-primary-500/20 dark:text-primary-200",
      label: "Em dia"
    },
    warning: {
      ring: "ring-warning/40",
      badge: "bg-warning/15 text-warning",
      label: "Atenção"
    },
    critical: {
      ring: "ring-danger/40",
      badge: "bg-danger/15 text-danger",
      label: "Urgente"
    },
    expired: {
      ring: "ring-danger ring-offset-danger/10",
      badge: "bg-danger text-white",
      label: "Vencido"
    }
  }.freeze

  def inventory_status(inventory_item)
    inventory_item.status
  end

  def inventory_status_ring(status)
    STATUS_STYLE_MAP.fetch(status, STATUS_STYLE_MAP[:healthy])[:ring]
  end

  def inventory_status_badge(status)
    STATUS_STYLE_MAP.fetch(status, STATUS_STYLE_MAP[:healthy])[:badge]
  end

  def inventory_status_label(status)
    STATUS_STYLE_MAP.fetch(status, STATUS_STYLE_MAP[:healthy])[:label]
  end

  def format_quantity(inventory_item)
    quantity = inventory_item.quantity || 0
    precision = inventory_item.unit_precision || 0
    formatted_quantity = if precision.positive?
                           number_with_precision(quantity, precision: precision)
                         else
                           quantity.to_i
                         end
    unit_label = inventory_item.unit_label
    unit_label.present? ? "#{formatted_quantity} #{unit_label}" : formatted_quantity.to_s
  end

  def unit_step_value(inventory_item)
    BigDecimal(inventory_item.custom_unit_step.to_s).to_s("F")
  end

  def format_measurement(value, inventory_item)
    precision = inventory_item.unit_precision || 0
    formatted = if precision.positive?
                  number_with_precision(value, precision: precision)
                else
                  value.to_i
                end
    unit_label = inventory_item.unit_label
    unit_label.present? ? "#{formatted} #{unit_label}" : formatted.to_s
  end

  def precision_step_value(inventory_item)
    precision = inventory_item.unit_precision || 0
    return unit_step_value(inventory_item) if precision <= 0

    (BigDecimal("1") / (10**precision)).to_s("F")
  rescue ArgumentError
    unit_step_value(inventory_item)
  end
end
