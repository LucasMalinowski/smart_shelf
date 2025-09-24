# frozen_string_literal: true

class InventoryItem < ApplicationRecord
  belongs_to :family
  belongs_to :item
  belongs_to :measurement_unit, optional: true

  delegate :category, to: :item

  before_save :reset_notification_flags
  after_commit :evaluate_notifications, on: :update

  validates :quantity, numericality: { greater_than_or_equal_to: 0 }
  validates :minimum_quantity, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :critical_quantity, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :custom_unit_step, numericality: { greater_than: 0 }

  scope :by_category, ->(category_id) { joins(item: :category).where(categories: { id: category_id }) }
  scope :low_stock, -> { where("minimum_quantity IS NOT NULL AND quantity <= minimum_quantity") }
  scope :critical_stock, -> { where("critical_quantity IS NOT NULL AND quantity <= critical_quantity") }
  scope :expired, -> { where("expires_at IS NOT NULL AND expires_at <= ?", Time.current) }
  scope :suggested_for_restock, lambda { |window = 2.days|
    cutoff = Time.current + window
    where(
      "(minimum_quantity IS NOT NULL AND quantity <= minimum_quantity) OR " \
      "(critical_quantity IS NOT NULL AND quantity <= critical_quantity) OR " \
      "(expires_at IS NOT NULL AND expires_at <= ?)",
      cutoff
    )
  }

  def unit_label
    custom_unit_name.presence || measurement_unit&.label || MeasurementUnit.default_unit&.label || "un"
  end

  def increment!(amount = custom_unit_step)
    amount = amount.to_d
    update!(quantity: quantity + amount, last_restocked_at: Time.current)
  end

  def decrement!(amount = custom_unit_step)
    amount = amount.to_d
    new_quantity = [quantity - amount, 0].max
    update!(quantity: new_quantity)
  end

  def status
    return :expired if expires_at.present? && expires_at <= Time.current

    return :critical if critical_quantity.present? && quantity <= critical_quantity

    return :warning if minimum_quantity.present? && quantity <= minimum_quantity

    :healthy
  end

  def threshold_reached?
    minimum_quantity.present? && quantity <= minimum_quantity
  end

  def critical?
    critical_quantity.present? && quantity <= critical_quantity
  end

  def needs_notification?(kind)
    case kind.to_sym
    when :low
      threshold_reached? && (low_stock_notified_at.blank? || low_stock_notified_at < 1.day.ago)
    when :critical
      critical? && (critical_stock_notified_at.blank? || critical_stock_notified_at < 6.hours.ago)
    when :expiration
      expires_at.present? && expires_at <= 3.days.from_now && (expiration_notified_at.blank? || expiration_notified_at < 1.day.ago)
    else
      false
    end
  end

  def mark_notified!(kind)
    case kind.to_sym
    when :low
      update_column(:low_stock_notified_at, Time.current)
    when :critical
      update_column(:critical_stock_notified_at, Time.current)
    when :expiration
      update_column(:expiration_notified_at, Time.current)
    end
  end

  def suggestion_reason
    return :expired if expires_at.present? && expires_at <= Time.current
    return :critical if critical?
    return :low if threshold_reached?

    :none
  end

  def suggestion_label
    case suggestion_reason
    when :expired then "Vencimento próximo"
    when :critical then "Estoque crítico"
    when :low then "Abaixo do limite"
    else
      ""
    end
  end

  def restock_suggestion_quantity
    target = case suggestion_reason
             when :critical
               critical_quantity
             when :low
               minimum_quantity
             else
               minimum_quantity || critical_quantity
             end

    step = custom_unit_step.presence || 1
    return step unless target.present?

    deficit = target - quantity
    deficit = step if deficit <= 0
    steps_needed = (deficit / step).ceil
    (steps_needed * step).round(3)
  end

  private

  def reset_notification_flags
    if minimum_quantity.present? && quantity > minimum_quantity
      self.low_stock_notified_at = nil
    end

    if critical_quantity.present? && quantity > critical_quantity
      self.critical_stock_notified_at = nil
    end

    if expires_at.blank? || expires_at > 7.days.from_now
      self.expiration_notified_at = nil
    end
  end

  def evaluate_notifications
    emit_notification!(:critical) if critical? && needs_notification?(:critical)
    emit_notification!(:low) if !critical? && threshold_reached? && needs_notification?(:low)
    emit_notification!(:expiration) if expires_at.present? && expires_at <= 3.days.from_now && needs_notification?(:expiration)
  end

  def emit_notification!(kind)
    family.family_notifications.create!(
      inventory_item: self,
      kind: kind,
      title: notification_title(kind),
      body: notification_body(kind),
      triggered_at: Time.current
    )

    mark_notified!(kind)
  end

  def notification_title(kind)
    case kind.to_sym
    when :critical
      "Estoque crítico: #{item.name}"
    when :low
      "Estoque baixo: #{item.name}"
    when :expiration
      "#{item.name} está vencendo"
    else
      item.name
    end
  end

  def notification_body(kind)
    case kind.to_sym
    when :critical
      "Restam #{formatted_quantity} #{unit_label} e o nível crítico configurado é #{format_decimal(critical_quantity)} #{unit_label}."
    when :low
      "Restam #{formatted_quantity} #{unit_label} do item e o limite mínimo é #{format_decimal(minimum_quantity)} #{unit_label}."
    when :expiration
      "O item expira em #{I18n.l(expires_at.to_date, format: :long)}. Providencie reposição ou consumo."
    else
      nil
    end
  end

  def formatted_quantity
    precision = unit_precision || 0
    if precision.positive?
      quantity.round(precision).to_s("F")
    else
      quantity.to_i.to_s
    end
  end

  def format_decimal(value)
    return "0" if value.blank?

    if unit_precision&.positive?
      BigDecimal(value.to_s).to_s("F")
    else
      value.to_i.to_s
    end
  end

end
