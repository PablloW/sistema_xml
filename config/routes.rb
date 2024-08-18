Rails.application.routes.draw do
  devise_for :users
  get 'documents/index'
  resources :documents
  resources :products
  
  root to:'documents#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resources :documents do
    member do
      get 'report'
    end
  end
end