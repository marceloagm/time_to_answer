Rails.application.routes.draw do
  namespace :site do
    get 'welcome/index'
    get 'resultados/index'
    get 'resultados/visualizar_resultados'
  end
  namespace :users_backoffice do
    get 'welcome/index'
    get 'resultados/index'
    get 'apostas/index'
    get 'resultados/visualizar_resultados'
    get 'perfil', to: 'perfil#edit'
    patch 'perfil', to: 'perfil#update'
    resources :equipes
    get 'time_cartola', to: 'time_cartola#show'
    resources :apostas
    
    get "rodada_atual", to: 'apostas#rodada_atual'
    get "rodada_prox", to: 'apostas#rodada_prox'
    get "rodada_dprox", to: 'apostas#rodada_dprox'
    get "rodada_ddprox", to: 'apostas#rodada_ddprox'
    get "minhas_apostas", to: 'apostas#minhas_apostas'
    get "teste", to: 'apostas#teste'
    get "pagamento", to: 'apostas#pagamento'

   
    
    
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
