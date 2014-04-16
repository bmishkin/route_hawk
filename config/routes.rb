RouteHawk::Engine.routes.draw do
  resources :roles, :except => [:show]
  root "roles#index"
end
