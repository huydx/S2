S2::Application.routes.draw do
  get "question/index"
  root "top#index"

  devise_for :users, controllers: {sessions: "sessions"}

  controller :streaming do
    get "streaming/search" => :search
    get "streaming/:id" => :index, as: :index
    post "streaming/register" => :register_channel
    post "streaming/remove" => :remove_channel
    get "streaming/:id/client" => :client
  end 

  controller :question do
    get ":id/question" => :index
  end

  resources :users, only: [:show]
  resources :home, only: [:index]
end
