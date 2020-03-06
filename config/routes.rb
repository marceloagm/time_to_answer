Rails.application.routes.draw do
  namespace :site do
    get 'welcome/index'
  end
  namespace :users_backoffice do
    get 'welcome/index'
    get 'perfil', to: 'perfil#edit'
    patch 'perfil', to: 'perfil#update'
  end
  namespace :admins_backoffice do
    get 'welcome/index' #Dashboard
    resources :admins  #Administradores
  end
  devise_for :users
  devise_for :admins, skip: [:registrations]
  
  get 'inicio', to: 'site/welcome#index'

  root to: 'site/welcome#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
