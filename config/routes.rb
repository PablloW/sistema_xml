Rails.application.routes.draw do
  # Rota para o índice de documentos como a página inicial
  root 'documents#index'

  # Rota para o relatório de documentos
  resources :documents do
    member do
      get 'report'
    end
  end

  # Configurações do Devise para autenticação de usuários
  devise_for :users

  # Rota para verificar o status da aplicação
  get "up" => "rails/health#show", as: :rails_health_check
end