S2::Application.routes.draw do
  root "home#index"

  devise_for :users, controllers: {registrations: "registrations"}

  controller :streaming do
    get "streaming/:id" => :index, as: :index
    get "streaming/search/:username" => :search
    post "streaming/register" => :register_channel
  end 

  resources :users, only: [:show]
end
