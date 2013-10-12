S2::Application.routes.draw do
  root "top#index"

  devise_for :users, controllers: {registrations: "registrations"}

  controller :streaming do
    get "streaming/:id" => :index, as: :index
  end

  resources :users, only: [:show]
  resources :home, only: [:index]
end
