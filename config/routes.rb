S2::Application.routes.draw do
  root "home#index"

  devise_for :users

  controller :streaming do
    get "streaming/:id" => :index, as: :index
  end

  resources :users, only: [:show]
end
