S2::Application.routes.draw do
  root "top#index"

  devise_for :users, controllers: {sessions: "sessions"}

  controller :answer do
    post "answer/create" => :create
    get "answer/index" => :index
  end

  controller :streaming do
    get "streaming/search" => :search
    get "streaming/:id" => :index, as: :index
    get "streaming/:id/client" => :client
    post "streaming/register" => :register_channel
    post "streaming/remove" => :remove_channel
  end

  controller :question do
    get ":id/question" => :index
    post "question/vote" => :vote
    get "question/ask_page" => :ask_page
    post "question/ask_post" => :ask_post
    post "question/add_answer" => :add_answer
    get ":id/question/all" => :all
  end

  resources :users, only: [:show]
  resources :home, only: [:index]
end
