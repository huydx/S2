S2::Application.routes.draw do
  controller :streaming do
    get "streaming/:id" => :index, as: :index
  end
end
