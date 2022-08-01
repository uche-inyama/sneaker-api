Rails.application.routes.draw do
  # devise_for :users
  devise_for :users, :controllers => {:registrations => "registrations", :sessions => "sessions" }
  resources :products 

  resources :products do
    resources :samples
  end
  
  get '/products', to: "products#index"
  post 'cart/:product_id/add', to: 'cart#add'
  delete 'cart/:id/remove', to: 'cart#destroy'

  unauthenticated do
    root to: "home#index", as: :unauthenticated_root
  end
  
  authenticated do
    root to: "home#index"
  end
end
