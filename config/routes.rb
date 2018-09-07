Rails.application.routes.draw do
  resources :permission_codes
  resources :workers
  resources :tasks
  resources :jobs
  resources :users

  root 'jobs#index'
  get '/login', to: 'sessions#new'
  post "/login", to: "sessions#create"
  delete "/login", to: "sessions#destroy"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
