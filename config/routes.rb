Rails.application.routes.draw do
  root 'pages#home'
  get '/admin/login', to: 'sessions#new', as: :login
  post '/admin/login', to: 'sessions#create'
  delete '/admin/logout', to: 'sessions#destroy', as: :logout
  namespace :admin do
    root 'settings#edit'
    resource :settings, only: %i[edit update destroy] do
    get :export
    post :import
  end
    resources :items, except: :show do
      patch :move, on: :member
    end
  end
end
