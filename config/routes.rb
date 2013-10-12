S2::Application.routes.draw do
  controller :streaming do
    get "streaming/:id" => :index, as: :index
    get "streaming/search/:username" => :search
    post "streaming/register" => :register_channel
  end 
end
