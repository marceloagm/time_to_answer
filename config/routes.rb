Rails.application.routes.draw do
  namespace :site do
    get 'welcome/index'
    get 'resultados/index'
    get 'resultados/visualizar_resultados'
    get 'visualizar_time/time'
    get 'search_resultados', to: 'search_resultados#resultado_encontrado'
  end
  namespace :users_backoffice do
    get 'welcome/index'
    get 'resultados/index'
    get 'search', to: 'search#time'
    get 'apostas/index'
    get 'resultados/visualizar_resultados'
    get 'search_resultados', to: 'search_resultados#resultado_encontrado'
    get 'visualizar_time/time'
    get 'perfil', to: 'perfil#edit'
    patch 'perfil', to: 'perfil#update'
    resources :equipes
    get 'time_cartola', to: 'time_cartola#show'
    resources :apostas
    
    get "rodada_atual", to: 'apostas#rodada_atual'
    post "rodada_atual", to: 'apostas#rodada_atual'
    get "rodada_prox", to: 'apostas#rodada_prox'
    post "rodada_prox", to: 'apostas#rodada_prox'
    get "rodada_dprox", to: 'apostas#rodada_dprox'
    post "rodada_dprox", to: 'apostas#rodada_dprox'
    get "rodada_ddprox", to: 'apostas#rodada_ddprox'
    post "rodada_ddprox", to: 'apostas#rodada_ddprox'
    get "minhas_apostas", to: 'apostas#minhas_apostas'
    get "escolher_time", to: 'apostas#escolher_time'    
    get "teste", to: 'apostas#teste'
    post "teste", to: 'apostas#teste'
        
    
    
  end
  namespace :admins_backoffice do
    get 'welcome/index' #Dashboard
    get "exibir_usuarios", to: 'users#exibir_usuarios' 
    get 'resultados/index'
    get 'resultados/visualizar_resultados'
    get 'equipes/visualizar_equipes'
    get 'resultados', to: 'resultados#edit'
    patch 'resultados', to: 'resultados#update'
    get 'equipes', to: 'equipes#edit'
    patch 'equipes', to: 'equipes#update' 
    get 'users', to: 'users#edit'
    patch 'users', to: 'users#update' 
    get 'search_user', to: 'search_user#usuario_encontrado'
    get 'search_resultados', to: 'search_resultados#resultado_encontrado'
    get 'search_equipe', to: 'search_equipe#equipe_encontrada'
    get "apostar", to: 'apostar#apostar_manual'
    post "apostar", to: 'apostar#apostar_manual'
  
    resources :admins  #Administradores
   
    
  end

  get '/404', to: 'errors#not_found'
  get '/422', to: 'errors#unacceptable'
  get '/500', to: 'errors#server_errors'

  devise_for :users
  devise_for :admins, skip: [:registrations]
  
  get 'inicio', to: 'site/welcome#index'

  root to: 'site/welcome#index'
  get 'index', to: 'parciais#index'
  get 'parciais', to: 'parciais#parciais'
  get 'salvar_equipe', to: 'parciais#salvar_equipe'
  get 'rodada_atual', to: 'parciais#rodada_atual'
  get 'salvar_atletas_pontuados', to: 'parciais#salvar_atletas_pontuados'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
