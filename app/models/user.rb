class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :family

  has_many :inventory_items, through: :family
  has_many :grocery_list_items, through: :family
  has_many :family_notifications, through: :family

  before_validation :ensure_family, on: :create

  private

  def ensure_family
    return if family.present?

    self.family = Family.new(name: default_family_name)
  end

  def default_family_name
    local_part = email.to_s.split("@").first.presence || "Família"
    "Família #{local_part.titleize}"
  end
end
