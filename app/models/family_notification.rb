# frozen_string_literal: true

class FamilyNotification < ApplicationRecord
  enum status: { unread: 0, read: 1, dismissed: 2 }

  belongs_to :family
  belongs_to :inventory_item, optional: true
  belongs_to :read_by, class_name: "User", optional: true

  validates :kind, presence: true
  validates :title, presence: true
  validates :status, presence: true

  scope :recent, -> { order(triggered_at: :desc) }
  scope :active, -> { unread.order(triggered_at: :desc) }

  def mark_as_read!(user = nil)
    update!(status: :read, read_by: user, read_at: Time.current)
  end
end
