S2::Application.routes.draw do
  root "top#index"

  devise_for :users, controllers: {sessions: "sessions"}

  controller :streaming do
    get "streaming/search" => :search
    get "streaming/:id" => :index, as: :index
    get "streaming/:id/sub" => :index
    post "streaming/register" => :register_channel
    post "streaming/remove" => :remove_channel
<<<<<<< HEAD
    get "streaming/:id/client" => :client
  end 
=======
  end
>>>>>>> Created url for subscribe

  resources :users, only: [:show]
  resources :home, only: [:index]
end
