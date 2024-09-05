class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :user_items
  has_many :grocery_list_items

  after_create :create_user_items

  private

  def create_user_items
    Item.all.each do |item|
      UserItem.create(user: self, item: item, quantity: 0)
    end
  end
end
