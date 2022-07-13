Rails.application.routes.draw do
  devise_for :users
  unauthenticated do
    root to: "home#index", as: :unauthenticated_root
  end
  resources :products
  authenticated do
    root to: "products#index"
  end
end
