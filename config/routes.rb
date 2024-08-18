Rails.application.routes.draw do
  devise_for :users
  get 'documents/index'
  resources :documents
  resources :products
  
  root to:'documents#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  post 'upload_documents', to: 'documents#upload'

  resources :documents do
    member do
      get 'report'
      get 'export_excel', to: 'documents#export_excel'
    end
  end
end