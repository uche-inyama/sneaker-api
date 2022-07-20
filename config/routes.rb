Rails.application.routes.draw do
  devise_for :users
  resources :products 

  resources :products do
    resources :samples
  end
  get '/products', to: "products#index"
  post 'cart/:product_id/add', to: 'cart#add'
  post 'cart/remove', to: 'cart#remove'

  unauthenticated do
    root to: "home#index", as: :unauthenticated_root
  end
  
  authenticated do
    root to: "home#index"
  end
end
