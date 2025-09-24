# frozen_string_literal: true

class FamilyInvitation < ApplicationRecord
  enum status: { pending: 0, accepted: 1, declined: 2, expired: 3 }

  belongs_to :family
  belongs_to :invited_by, class_name: "User"

  before_validation :normalize_email
  before_validation :ensure_token, on: :create

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :token, presence: true, uniqueness: true
  validates :status, presence: true

  scope :active, -> { where(status: :pending).where("expires_at IS NULL OR expires_at > ?", Time.current) }

  def accept!(user)
    transaction do
      user.update!(family: family)
      update!(status: :accepted)
    end
  end

  def expired?
    expires_at.present? && expires_at < Time.current
  end

  private

  def normalize_email
    self.email = email.to_s.downcase.strip
  end

  def ensure_token
    self.token ||= SecureRandom.hex(12)
  end
end
