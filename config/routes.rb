Rails.application.routes.draw do
  get 'grocery_list/index'
  devise_for :users
  get "up" => "rails/health#show", as: :rails_health_check
  root 'items#index'
  resources :items, only: [:index]
  resources :user_items, only: [:create, :update, :destroy]
  resources :grocery_list_items, only: [:create, :update, :destroy]
  get 'grocery_list', to: 'grocery_list#index'
end
