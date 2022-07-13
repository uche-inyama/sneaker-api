Rails.application.routes.draw do
  devise_for :users
  resources :products
  resources :companies
  unauthenticated do
    root to: "home#index", as: :unauthenticated_root
  end
 
  authenticated do
    root to: "products#index"
  end
end
