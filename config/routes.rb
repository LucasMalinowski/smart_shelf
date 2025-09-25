Rails.application.routes.draw do
  get 'grocery_list/index'
  devise_for :users
  get "up" => "rails/health#show", as: :rails_health_check
  root 'items#index'
  resources :items, only: [:index]
  resources :inventory_items, only: [:create, :update, :destroy]
  resources :grocery_list_items, only: [:create, :update, :destroy]
  resources :family_notifications, only: [:update] do
    patch :mark_all, on: :collection
  end
  resource :theme, only: [:update]
  resource :settings, only: [:show] do
    patch :category_order, on: :collection
  end
  resources :hidden_inventory_items, only: [:create, :destroy]
  get 'grocery_list', to: 'grocery_list#index'
end
