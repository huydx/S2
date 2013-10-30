S2::Application.routes.draw do
  root "top#index"

  devise_for :users, controllers: {sessions: "sessions"}

  controller :streaming do
    get "streaming/search" => :search
    get "streaming/:id" => :index, as: :index
    get "streaming/:id/client" => :index
    post "streaming/register" => :register_channel
    post "streaming/remove" => :remove_channel
  end

  resources :users, only: [:show]
  resources :home, only: [:index]
end
